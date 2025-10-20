#!/bin/bash
#
# Bu script, /var/www/html klasörünü yedekler
# ve 7 günden eski yedekleri otomatik siler.
#
BACKUP_DIR="/backup"
TIMESTAMP=$(date +"%Y-m-%d_%H-%M")
BACKUP_NAME="backup-${TIMESTAMP}.tar.gz"

# Yedekle
sudo tar -czf ${BACKUP_DIR}/${BACKUP_NAME} -C /var/www/ html

# 7 günden eski yedekleri sil
sudo find ${BACKUP_DIR} -name "backup-*.tar.gz" -type f -mtime +7 -exec rm {} \;

echo "Yedekleme tamamlandı: ${BACKUP_DIR}/${BACKUP_NAME}"
echo "Eski yedekler temizlendi."
