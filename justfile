blueprint_root := "./"
pterodactyl_dir := "pterodactyl"
db_connection := "mysql"
db_username := "pterodactyl"
db_password := "pterodactyl"
db_port := "3006"
app_url := "http://localhost:3000"
app_debug := "true"
USERSHELL := "/bin/bash"

default: setup_dev install_blueprint dev

blueprintrc:
    #!/usr/bin/env bash
    export user=$(whoami)

    cat > .blueprintrc << EOF
    WEBUSER="$user"
    OWNERSHIP="$user:$user"
    USERSHELL="{{ USERSHELL }}"
    SHORTCUT_DIR=""
    EOF

setup_dev: check-deps blueprintrc
    #!/usr/bin/env bash
    set -euo pipefail

    if [ ! -d {{ pterodactyl_dir }} ]; then
        git clone https://github.com/pterodactyl/panel.git {{ pterodactyl_dir }}
    fi
    git -C {{ pterodactyl_dir }} pull || true

    cd {{ pterodactyl_dir }}

    cp -n .env.example .env

    composer update
    composer i
    php artisan key:generate --force -n

    yarn install
    just env_replace {{ pterodactyl_dir }}/.env DB_CONNECTION {{ db_connection }}
    just env_replace {{ pterodactyl_dir }}/.env DB_USERNAME {{ db_username }}
    just env_replace {{ pterodactyl_dir }}/.env DB_PASSWORD {{ db_password }}
    just env_replace {{ pterodactyl_dir }}/.env DB_PORT {{ db_port }}

    just env_replace {{ pterodactyl_dir }}/.env APP_URL {{ app_url }}
    just env_replace {{ pterodactyl_dir }}/.env APP_DEBUG {{ app_debug }}
    just env_replace {{ pterodactyl_dir }}/.env APP_ENVIRONMENT_ONLY false
    just env_replace {{ pterodactyl_dir }}/.env RECAPTCHA_ENABLED false

    just start_db
    php artisan migrate --force -n

    php artisan p:user:make --email=dev@dev.com --username=dev --name-first=dev --name-last=dev --password=dev --admin=yes 2>/dev/null || true
    docker exec blueprint-dev-db mysql -uroot -proot -e "USE panel; UPDATE users SET root_admin = 1 WHERE email = 'dev@dev.com';"

install_blueprint:
    #!/usr/bin/env bash
    set -euo pipefail

    export BLUEPRINT_ENVIRONMENT="ci"
    export SHORTCUT_DIR=""
    echo "Syncing Blueprint files to Pterodactyl..."

    rsync -av \
        --exclude='{{ pterodactyl_dir }}' \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='vendor' \
        --exclude='.env' \
        --exclude='justfile' \
        --exclude='LICENSE.md' \
        --exclude='README.md' \
        --exclude='CODE_OF_CONDUCT.md' \
        --exclude='SECURITY.md' \
        {{ blueprint_root }} {{ pterodactyl_dir }}/ \

    chmod +x {{ pterodactyl_dir }}/blueprint.sh

    cd {{ pterodactyl_dir }}
    rm -f .blueprint/data/internal/db/installed

    bash blueprint.sh -bash -rerun-install

watch_sync:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Watching Blueprint framework for changes..."
    echo "📂 Syncing to: {{ pterodactyl_dir }}"

    inotifywait -m -r \
        -e modify,create,move \
        --exclude '({{ pterodactyl_dir }}|\.git|node_modules|vendor|\.env|justfile)' \
        --format '%w%f' \
        . | while read -r filepath; do

        [[ -f "$filepath" ]] || continue

        relpath="${filepath#./}"

        # Remap blueprint/ to .blueprint/
        if [[ "$relpath" == blueprint/* ]]; then
            relpath=".blueprint/${relpath#blueprint/}"
        fi

        destpath="{{ pterodactyl_dir }}/$relpath"
        mkdir -p "$(dirname "$destpath")"

        if cp "$filepath" "$destpath" 2>/dev/null; then
            echo "[$(date +%H:%M:%S)] ✓ $relpath"
        fi
    done

start_db:
    #!/usr/bin/env bash
    if [ "$(docker ps -aq -f name=blueprint-dev-db)" ]; then
        docker start blueprint-dev-db
    else
        docker run -d \
          --name blueprint-dev-db \
          -e MYSQL_ROOT_PASSWORD=root \
          -e MYSQL_DATABASE=panel \
          -e MYSQL_USER={{ db_username }} \
          -e MYSQL_PASSWORD={{ db_password }} \
          -p {{ db_port }}:3306 \
          mysql:9
    fi
    until docker exec blueprint-dev-db sh -c "mysql -uroot -proot -e 'SELECT 1;'"; do
        echo "Waiting for database..."
        sleep 2
    done

    docker exec blueprint-dev-db mysql -uroot -proot -e "SET GLOBAL sql_mode='';"
    docker exec blueprint-dev-db mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS panel;"
    docker exec blueprint-dev-db mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO '{{ db_username }}'@'%'; FLUSH PRIVILEGES;"

stop_db:
    docker stop blueprint-dev-db
    docker rm blueprint-dev-db

dev: blueprintrc start_db
    # php artisan serve --port=5000
    # yarn watch
    tmux new-session -s dev \; \
      send-keys 'cd {{ pterodactyl_dir }} && php artisan serve --port=5000' C-m \; \
      split-window -h \; \
      send-keys 'cd {{ pterodactyl_dir }} && yarn watch' C-m \; \
      split-window -v \; \
      send-keys 'just watch_sync' C-m

check-deps:
    @command -v git >/dev/null 2>&1 || { echo "git is required but not installed"; exit 1; }
    @command -v docker >/dev/null 2>&1 || { echo "docker is required but not installed"; exit 1; }
    @command -v php >/dev/null 2>&1 || { echo "php is required but not installed"; exit 1; }
    @command -v composer >/dev/null 2>&1 || { echo "composer is required but not installed"; exit 1; }
    @command -v node >/dev/null 2>&1 || { echo "node is required but not installed"; exit 1; }
    @command -v yarn >/dev/null 2>&1 || { echo "yarn is required but not installed"; exit 1; }
    @command -v mariadb >/dev/null 2>&1 || { echo "mariadb-clients is required but not installed"; exit 1; }
    @command -v inotifywait >/dev/null 2>&1 || { echo "inotify-tools is required but not installed"; exit 1; }
    @command -v tmux >/dev/null 2>&1 || { echo "tmux is required but not installed"; exit 1; }
    @command -v rsync >/dev/null 2>&1 || { echo "rsync is required but not installed"; exit 1; }

env_replace file key value:
    #!/usr/bin/env bash
    set -euo pipefail

    if grep -q "^{{ key }}=" "{{ file }}"; then
        sed -i "s|^{{ key }}=.*|{{ key }}={{ value }}|" "{{ file }}"
    else
        echo "{{ key }}={{ value }}" >> "{{ file }}"
    fi
