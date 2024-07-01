#!/bin/bash

# Load configuration
source ../config/backup_config.sh

# Create a timestamp
TIMESTAMP=$(date +"%F_%H-%M-%S")

# Define backup file name and directory
BACKUP_FILE="$BACKUP_DIR/incremental_backup_$TIMESTAMP.sql"

# Perform the incremental backup using pg_dump
# Dump only the data that has changed since the last backup
pg_dump -h $PG_HOST -p $PG_PORT -U $PG_USER -F c -b -v -a -t $PG_DATABASE -f $BACKUP_FILE

# Check if the backup was successful
if [ $? -eq 0 ]; then
  echo "[$(date)] Incremental backup successful: $BACKUP_FILE" >> ../logs/backup.log
else
  echo "[$(date)] Incremental backup failed" >> ../logs/backup.log
fi

# Upload the backup to AWS S3
python3 ../s3/upload_to_s3.py $BACKUP_FILE

# Check if the upload was successful
if [ $? -eq 0 ]; then
  echo "[$(date)] Backup uploaded to S3 successfully: $BACKUP_FILE" >> ../logs/backup.log
else
  echo "[$(date)] Backup upload to S3 failed" >> ../logs/backup.log
fi
