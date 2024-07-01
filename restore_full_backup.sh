#!/bin/bash

# Load configuration
source ../config/backup_config.sh

# Check if the backup file is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/full_backup_file"
  exit 1
fi

BACKUP_FILE=$1

# Check if the backup file exists
if [ ! -f $BACKUP_FILE ]; then
  echo "Backup file not found: $BACKUP_FILE"
  exit 1
fi

# Perform the restoration using pg_restore
pg_restore -h $PG_HOST -p $PG_PORT -U $PG_USER -d $PG_DATABASE -v $BACKUP_FILE

# Check if the restoration was successful
if [ $? -eq 0 ]; then
  echo "[$(date)] Full backup restoration successful: $BACKUP_FILE" >> ../logs/restore.log
else
  echo "[$(date)] Full backup restoration failed" >> ../logs/restore.log
fi
