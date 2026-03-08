blueprint_root := "./"
pterodactyl_dir := "./pterodactyl"
db_connection := "mysql"
db_username := "pterodactyl"
db_password := "pterodactyl"
db_port := "3006"
app_url := "http://localhost:3000"
app_debug := "true"

default: setup_dev

setup_dev: check-deps
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
    php artisan key:generate --force

    yarn install
    just env_replace {{ pterodactyl_dir }}/.env DB_CONNECTION {{ db_connection }}
    just env_replace {{ pterodactyl_dir }}/.env DB_USERNAME {{ db_username }}
    just env_replace {{ pterodactyl_dir }}/.env DB_PASSWORD {{ db_password }}
    just env_replace {{ pterodactyl_dir }}/.env DB_PORT {{ db_port }}

    just env_replace {{ pterodactyl_dir }}/.env APP_URL {{ app_url }}
    just env_replace {{ pterodactyl_dir }}/.env APP_DEBUG {{ app_debug }}
    just env_replace {{ pterodactyl_dir }}/.env APP_ENVIRONMENT_ONLY false

    just start_db
    php artisan migrate --force

    php artisan p:user:make --email=dev@dev.com --username=dev --name-first=dev --name-last=dev --password=dev --admin=yes 2>/dev/null || true
    docker exec blueprint-dev-db mysql -uroot -proot -e "USE panel; UPDATE users SET root_admin = 1 WHERE email = 'dev@dev.com';"

    just dev

apply-core:
    rsync -av --delete \
      --exclude='.git' --exclude='node_modules' --exclude='pterodactyl' --exclude='justfile' \
      {{ blueprint_root }}app/          {{ pterodactyl_dir }}/app/
    rsync -av --delete {{ blueprint_root }}blueprint/   {{ pterodactyl_dir }}/blueprint/
    rsync -av --delete {{ blueprint_root }}resources/   {{ pterodactyl_dir }}/resources/
    rsync -av --delete {{ blueprint_root }}routes/      {{ pterodactyl_dir }}/routes/
    rsync -av --delete {{ blueprint_root }}public/      {{ pterodactyl_dir }}/public/

    cp {{ blueprint_root }}blueprint.sh {{ pterodactyl_dir }}/blueprint.sh
    chmod +x {{ pterodactyl_dir }}/blueprint.sh

    rsync -av {{ blueprint_root }}scripts/ {{ pterodactyl_dir }}

reinstall-blueprint: apply-core
    cd {{ pterodactyl_dir }}
    bash blueprint.sh
    php artisan optimize:clear
    php artisan view:clear
    php artisan config:clear
    php artisan route:clear

core-dev: apply-core reinstall-blueprint start_db dev

quick-apply: apply-core
    cd {{ pterodactyl_dir }}
    php artisan optimize:clear  # minimal cache clear
    blueprint -build  # if already installed, to re-apply extension logic if relevant

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

dev: start_db
    # php artisan serve --port=5000
    # yarn watch
    tmux new-session -s dev \; \
      send-keys 'cd {{ pterodactyl_dir }} && php artisan serve --port=5000' C-m \; \
      split-window -h \; \
      send-keys 'cd {{ pterodactyl_dir }} && yarn watch' C-m

check-deps:
    @command -v git >/dev/null 2>&1 || { echo "git is required but not installed"; exit 1; }
    @command -v docker >/dev/null 2>&1 || { echo "docker is required but not installed"; exit 1; }
    @command -v php >/dev/null 2>&1 || { echo "php is required but not installed"; exit 1; }
    @command -v composer >/dev/null 2>&1 || { echo "composer is required but not installed"; exit 1; }
    @command -v node >/dev/null 2>&1 || { echo "node is required but not installed"; exit 1; }
    @command -v yarn >/dev/null 2>&1 || { echo "yarn is required but not installed"; exit 1; }
    @command -v mariadb >/dev/null 2>&1 || { echo "mariadb-clients is required but not installed"; exit 1; }

env_replace file key value:
    #!/usr/bin/env bash
    set -euo pipefail

    if grep -q "^{{ key }}=" "{{ file }}"; then
        sed -i "s|^{{ key }}=.*|{{ key }}={{ value }}|" "{{ file }}"
    else
        echo "{{ key }}={{ value }}" >> "{{ file }}"
    fi
