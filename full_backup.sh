#!/bin/bash

# Load configuration
source ../config/backup_config.sh

# Create a timestamp
TIMESTAMP=$(date +"%F")

# Define backup file name and directory
BACKUP_FILE="$BACKUP_DIR/full_backup_$TIMESTAMP.sql"

# Perform the full backup using pg_dump
pg_dump -h $PG_HOST -p $PG_PORT -U $PG_USER -F c -b -v -f $BACKUP_FILE $PG_DATABASE

# Check if the backup was successful
if [ $? -eq 0 ]; then
  echo "[$(date)] Full backup successful: $BACKUP_FILE" >> ../logs/backup.log
else
  echo "[$(date)] Full backup failed" >> ../logs/backup.log
fi

# Upload the backup to AWS S3
python3 ../s3/upload_to_s3.py $BACKUP_FILE

# Check if the upload was successful
if [ $? -eq 0 ]; then
  echo "[$(date)] Backup uploaded to S3 successfully: $BACKUP_FILE" >> ../logs/backup.log
else
  echo "[$(date)] Backup upload to S3 failed" >> ../logs/backup.log
fi
