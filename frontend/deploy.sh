#!/bin/bash
set -xe

echo "DEBUG: VERSION=${VERSION}"

# Скачиваем архив с собранным фронтендом из Nexus
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

ARTIFACT_URL="${NEXUS_REPO_URL}/${NEXUS_REPO_FRONTEND_NAME}/${VERSION}/sausage-store-${VERSION}.tar.gz"
echo "Downloading from: $ARTIFACT_URL"

curl -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" \
  -o sausage-store.tar.gz \
  "$ARTIFACT_URL"

# Проверяем архив
ls -lh sausage-store.tar.gz
file sausage-store.tar.gz

# Распаковываем (внутри архива папка 'frontend' со статикой)
tar -xzf sausage-store.tar.gz

# Копируем собранные файлы в целевую директорию
sudo rm -rf /var/www-data/dist/frontend/*
sudo cp -rf frontend/* /var/www-data/dist/frontend/

# Копируем и применяем конфиг nginx
if [ -f sausage-store-frontend.conf ]; then
    sudo cp -f sausage-store-frontend.conf /etc/nginx/sites-available/sausage-store-frontend
    sudo ln -sf /etc/nginx/sites-available/sausage-store-frontend /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
    sudo nginx -t
    sudo systemctl reload nginx
else
    echo "INFO: nginx config file not found, skipping nginx configuration"
fi

# Очистка
cd /
rm -rf "$TEMP_DIR"

echo "Frontend deployment completed successfully"