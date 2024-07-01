#!/bin/bash

# Load configuration
source ../config/backup_config.sh

# Define the paths to the backup scripts
FULL_BACKUP_SCRIPT="/path/to/your/repo/backup/full_backup.sh"
INCREMENTAL_BACKUP_SCRIPT="/path/to/your/repo/backup/incremental_backup.sh"

# Ensure the backup scripts are executable
chmod +x $FULL_BACKUP_SCRIPT
chmod +x $INCREMENTAL_BACKUP_SCRIPT

# Schedule full backup at 2 AM every Sunday
(crontab -l 2>/dev/null; echo "0 2 * * 0 $FULL_BACKUP_SCRIPT") | crontab -

# Schedule incremental backup at 2 AM every day
(crontab -l 2>/dev/null; echo "0 2 * * * $INCREMENTAL_BACKUP_SCRIPT") | crontab -

echo "Backup schedules added to cron."
