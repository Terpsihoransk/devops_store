#!/bin/bash
set -xe

# Проверим, что переменная передаётся из gitlab-ci
echo "DEBUG: VERSION=${VERSION}"

# Копируем unit-файл в systemd
sudo cp -f sausage-store-backend.service /etc/systemd/system/sausage-store-backend.service

# Скачиваем артефакт во временную директорию
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"
curl -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" \
  -o sausage-store.jar \
  "${NEXUS_REPO_URL}/repository/${NEXUS_REPO_BACKEND_NAME}/com/yandex/practicum/devops/sausage-store/${VERSION}/sausage-store-${VERSION}.jar"

# Копируем jar в домашнюю директорию
sudo cp -f sausage-store.jar /home/student/sausage-store.jar

# Даём права
sudo chown student:student /home/student/sausage-store.jar

# Удаляем временную директорию
cd /
rm -rf "$TEMP_DIR"

# Перезагружаем systemd и сервис
sudo systemctl daemon-reload
sudo systemctl restart sausage-store-backend