blueprint_root := "./"
pterodactyl_dir := "pterodactyl"
db_connection := "mysql"
db_username := "pterodactyl"
db_password := "pterodactyl"
db_port := "3006"
app_url := "http://localhost"
app_debug := "true"
USERSHELL := "/bin/bash"

default: dev

setup: check_dev stop_db stop_wings setup_dev install_blueprint setup_wings dev

blueprintrc:
    #!/usr/bin/env bash
    export user=$(whoami)

    cat > .blueprintrc << EOF
    WEBUSER="$user"
    OWNERSHIP="$user:$user"
    USERSHELL="{{ USERSHELL }}"
    SHORTCUT_DIR=""
    EOF

check_dev:
    #!/usr/bin/env bash
    if [ -d {{ pterodactyl_dir }} ]; then
        echo "Pterodactyl Dir exists, delete it to rerun setup"
        exit 1
    fi

setup_dev: check-deps blueprintrc
    #!/usr/bin/env bash
    set -euo pipefail
    git clone https://github.com/pterodactyl/panel.git {{ pterodactyl_dir }}
    git -C {{ pterodactyl_dir }} pull || true

    cd {{ pterodactyl_dir }}

    if [ ! -f ".env" ]; then
        cp -n .env.example .env
    fi

    composer update
    composer i
    if ! grep -q "^APP_KEY=base64:" .env; then
      php artisan key:generate -n
    fi

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
    php artisan migrate --seed --force -n

    php artisan p:user:make --email=dev@dev.com --username=dev --name-first=dev --name-last=dev --password=dev --admin=yes 2>/dev/null || true
    if [ ! -f "{{ pterodactyl_dir }}/srv/etc/config.yml" ]; then
        php artisan p:location:make --short=dev --long=dev -qn  2>/dev/null || true
        php artisan p:node:make --fqdn=127.0.0.1 --name=dev-node --description=dev-node --locationId=1 --public=1 --scheme=http --proxy=0 --maxMemory=10240 --overallocateMemory=0 --maxDisk=10240 --overallocateDisk=0 --uploadSize=1024 --daemonListeningPort=8080 --daemonSFTPPort=2022 --maintenance=0 -n 2>/dev/null || true
    fi

    docker exec blueprint-dev-db mysql -uroot -proot -e "USE panel; UPDATE users SET root_admin = 1 WHERE email = 'dev@dev.com';"  2>/dev/null || true
    docker exec blueprint-dev-db mysql -uroot -proot -e "USE panel; INSERT INTO allocations (id, node_id, ip, ip_alias, port, server_id, notes, created_at, updated_at) VALUES (1, 1, '0.0.0.0', NULL, 25565, NULL, NULL, NOW(), NOW());" 2>/dev/null || true
    docker exec blueprint-dev-db mysql -uroot -proot -e "USE panel; INSERT INTO allocations (id, node_id, ip, ip_alias, port, server_id, notes, created_at, updated_at) VALUES (2, 1, '0.0.0.0', NULL, 25566, NULL, NULL, NOW(), NOW());" 2>/dev/null || true
    docker exec blueprint-dev-db mysql -uroot -proot -e "USE panel; INSERT INTO allocations (id, node_id, ip, ip_alias, port, server_id, notes, created_at, updated_at) VALUES (3, 1, '0.0.0.0', NULL, 25567, NULL, NULL, NOW(), NOW());" 2>/dev/null || true

    # Fix ownership for current user (relative paths since we're in pterodactyl_dir)
    sudo chown -R $(id -u):$(id -g) storage bootstrap/cache

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

    bash blueprint.sh -bash -rerun-install

setup_wings: check-deps stop_wings
    mkdir -p "./{{ pterodactyl_dir }}/srv/tmp/pterodactyl"
    mkdir -p "./{{ pterodactyl_dir }}/srv/var/lib/pterodactyl"
    mkdir -p "./{{ pterodactyl_dir }}/srv/var/lib/pterodactyl/volumes"
    mkdir -p "./{{ pterodactyl_dir }}/srv/etc"
    -php ./{{ pterodactyl_dir }}/artisan p:node:configuration 1 > {{ pterodactyl_dir }}/srv/etc/config.yml

    docker run \
      -d \
      --privileged \
      --name blueprint-dev-wings \
      --restart unless-stopped \
      --network host \
      -v "/var/run/docker.sock:/var/run/docker.sock" \
      -v "/var/lib/docker/:/var/lib/docker" \
      -v "./{{ pterodactyl_dir }}/srv/tmp/pterodactyl:/tmp/pterodactyl" \
      -v "./{{ pterodactyl_dir }}/srv/var/lib/pterodactyl:/var/lib/pterodactyl" \
      -v "./{{ pterodactyl_dir }}/srv/etc:/etc/pterodactyl/" \
      ghcr.io/pterodactyl/wings:latest

stop_wings:
    -@docker stop blueprint-dev-wings
    -@docker rm blueprint-dev-wings

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

php-image:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! docker image inspect php:8.3-fpm-pdo >/dev/null 2>&1; then
        echo "Building PHP 8.3 FPM image with pdo_mysql..."
        echo 'RlJPTSBwaHA6OC4zLWZwbQpSVU4gZG9ja2VyLXBocC1leHQtaW5zdGFsbCBwZG9fbXlzcWwKUlVOIGFwdC1nZXQgdXBkYXRlICYmIGFwdC1nZXQgaW5zdGFsbCAteSBzdWRvClJVTiB1c2VybW9kIC11IDEwMDAgd3d3LWRhdGEgMj4vZGV2L251bGwgfHwgdHJ1ZQpSVU4gZ3JvdXBtb2QgLWcgMTAwMCB3d3ctZGF0YSAyPi9kZXYvbnVsbCB8fCB0cnVlCg==' | base64 -d | docker build -t php:8.3-fpm-pdo -
    else
        echo "PHP image with pdo_mysql already exists."
    fi

nginx-image:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! docker image inspect nginx:latest-user >/dev/null 2>&1; then
        echo "Building Nginx image with user permissions..."
        echo 'RlJPTSBuZ2lueDpsYXRlc3QKUlVOIG1rZGlyIC1wIC92YXIvY2FjaGUvbmdpbngvY2xpZW50X3RlbXAgL3Zhci9ydW4vbmdpbnggJiYgXAogICAgY2hvd24gLVIgMTAwMDoxMDAwIC92YXIvY2FjaGUvbmdpbnggL3Zhci9ydW4vbmdpbnggL3Zhci9sb2cvbmdpbnggL2V0Yy9uZ2lueC9jb25mLmQgJiYgXAogICAgc2VkIC1pICdzL3VzZXIgbmdpbng7L3VzZXIgMTAwMDoxMDAwOy8nIC9ldGMvbmdpbngvbmdpbnguY29uZgo=' | base64 -d | docker build -t nginx:latest-user -
    else
        echo "Nginx image with user permissions already exists."
    fi

start_panel: php-image
    docker run --rm \
      --name blueprint-dev-php \
      --network host \
      -u $(id -u):$(id -g) \
      -v "$(pwd)/{{ pterodactyl_dir }}:/var/www/html" \
      -w /var/www/html \
      php:8.3-fpm-pdo

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
    -@docker stop blueprint-dev-db
    -@docker rm blueprint-dev-db

dev: blueprintrc start_db php-image nginx-image
    # Clean up existing containers and tmux session
    -@tmux kill-session -t dev 2>/dev/null || true
    -@docker stop blueprint-dev-php blueprint-dev-nginx 2>/dev/null || true
    -@docker rm blueprint-dev-php blueprint-dev-nginx 2>/dev/null || true
    # Generate nginx config if missing
    -@test -f {{ pterodactyl_dir }}/nginx.conf || just nginx-config
    # Start development environment in tmux
    tmux new-session -s dev \; \
      send-keys 'docker run --rm --name blueprint-dev-php --network host -u $(id -u):$(id -g) -v "$(pwd)/{{ pterodactyl_dir }}:/var/www/html" -w /var/www/html php:8.3-fpm-pdo' C-m \; \
      split-window -h \; \
      send-keys 'docker run --rm --name blueprint-dev-nginx --network host -v "$(pwd)/{{ pterodactyl_dir }}/public:/var/www/html/public" -v "$(pwd)/{{ pterodactyl_dir }}/nginx.conf:/etc/nginx/conf.d/default.conf" nginx:latest-user nginx -g "daemon off;"' C-m \; \
      split-window -v \; \
      send-keys 'cd {{ pterodactyl_dir }} && yarn watch' C-m \; \
      split-window -v \; \
      send-keys 'just watch_sync' C-m

nginx-config:
    #!/usr/bin/env bash
    set -euo pipefail

    CONFIG_FILE="{{ pterodactyl_dir }}/nginx.conf"

    echo "Creating Nginx config at ${CONFIG_FILE}..."

    base64 -d <<< 'c2VydmVyIHsKICAgIGxpc3RlbiA4MCBkZWZhdWx0X3NlcnZlcjsKICAgIHNlcnZlcl9uYW1lIF87CgogICAgcm9vdCAvdmFyL3d3dy9odG1sL3B1YmxpYzsKICAgIGluZGV4IGluZGV4LnBocDsKCiAgICBjbGllbnRfbWF4X2JvZHlfc2l6ZSAxMDBtOwogICAgY2xpZW50X2JvZHlfdGltZW91dCAxMjBzOwoKICAgIGFjY2Vzc19sb2cgL3Zhci9sb2cvbmdpbngvcHRlcm9kYWN0eWwuYWNjZXNzLmxvZzsKICAgIGVycm9yX2xvZyAvdmFyL2xvZy9uZ2lueC9wdGVyb2RhY3R5bC5lcnJvci5sb2cgd2FybjsKCiAgICBsb2NhdGlvbiAvIHsKICAgICAgICB0cnlfZmlsZXMgJHVyaSAkdXJpLyAvaW5kZXgucGhwPyRxdWVyeV9zdHJpbmc7CiAgICB9CgogICAgbG9jYXRpb24gfiBcLnBocCQgewogICAgICAgIGZhc3RjZ2lfcGFzcyAxMjcuMC4wLjE6OTAwMDsKICAgICAgICBmYXN0Y2dpX2luZGV4IGluZGV4LnBocDsKICAgICAgICBmYXN0Y2dpX3BhcmFtIFNDUklQVF9GSUxFTkFNRSAkZG9jdW1lbnRfcm9vdCRmYXN0Y2dpX3NjcmlwdF9uYW1lOwogICAgICAgIGluY2x1ZGUgZmFzdGNnaV9wYXJhbXM7CiAgICAgICAgZmFzdGNnaV9wYXJhbSBQSFBfVkFMVUUgInVwbG9hZF9tYXhfZmlsZXNpemU9MTAwbVxucG9zdF9tYXhfc2l6ZT0xMDBtIjsKICAgIH0KCiAgICBsb2NhdGlvbiB+KiBcLihqcGd8anBlZ3xnaWZ8cG5nfGljb3xjc3N8anN8c3ZnfHdvZmZ8dHRmfGVvdCkkIHsKICAgICAgICBleHBpcmVzIDMwZDsKICAgICAgICBhY2Nlc3NfbG9nIG9mZjsKICAgICAgICBhZGRfaGVhZGVyIENhY2hlLUNvbnRyb2wgInB1YmxpYyI7CiAgICB9CgogICAgbG9jYXRpb24gPSAvZmF2aWNvbi5pY28geyBhY2Nlc3NfbG9nIG9mZjsgbG9nX25vdF9mb3VuZCBvZmY7IH0KICAgIGxvY2F0aW9uID0gL3JvYm90cy50eHQgIHsgYWNjZXNzX2xvZyBvZmY7IGxvZ19ub3RfZm91bmQgb2ZmOyB9CgogICAgbG9jYXRpb24gfiAvXC5lbnZ8L1wuZ2l0fC9cLmJsdWVwcmludCB7CiAgICAgICAgZGVueSBhbGw7CiAgICAgICAgcmV0dXJuIDQwNDsKICAgIH0KfQo=' > "${CONFIG_FILE}"

    if [ $? -eq 0 ]; then
        echo "Nginx config written to ${CONFIG_FILE}"
        ls -l "${CONFIG_FILE}"
    else
        echo "Failed to create nginx config"
        exit 1
    fi

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
