# Automated Backup and Recovery System

## Overview

This project involves developing a comprehensive backup and recovery system for a PostgreSQL database. It includes scripts for performing full and incremental backups, automated scheduling, restoration processes, and integration with AWS S3 for remote storage.

## Technologies

- PostgreSQL
- Bash
- Python
- AWS S3

## Key Features

- Full and incremental backup scripts
- Automated scheduling
- Restoration scripts
- Integration with AWS S3 for remote storage

## Project Structure

```
automated-backup-recovery/
├── backup/
│   ├── full_backup.sh
│   ├── incremental_backup.sh
│   └── schedule_backups.sh
├── restore/
│   ├── restore_full_backup.sh
│   ├── restore_incremental_backup.sh
├── s3/
│   ├── upload_to_s3.py
│   ├── download_from_s3.py
├── config/
│   ├── backup_config.sh
│   ├── aws_config.py
├── logs/
│   ├── backup.log
│   ├── restore.log
├── README.md
└── LICENSE
```

## Instructions

### 1. Clone the Repository

Start by cloning the repository to your local machine:

```bash
git clone https://github.com/your-username/automated-backup-recovery.git
cd automated-backup-recovery
```

### 2. Configure Backup and AWS Settings

Update the configuration files with your PostgreSQL and AWS settings.

#### `config/backup_config.sh`

```bash
#!/bin/bash

# PostgreSQL configuration
PG_HOST="your_pg_host"
PG_PORT="your_pg_port"
PG_USER="your_pg_user"
PG_DATABASE="your_pg_database"
BACKUP_DIR="/path/to/your/backup/dir"

# AWS S3 configuration
S3_BUCKET="your_s3_bucket_name"
```

#### `config/aws_config.py`

```python
AWS_ACCESS_KEY = 'your_aws_access_key'
AWS_SECRET_KEY = 'your_aws_secret_key'
S3_BUCKET_NAME = 'your_s3_bucket_name'
BACKUP_DIR = '/path/to/your/backup/dir'
```

### 3. Perform Full Backup

Run the full backup script to create a complete backup of your PostgreSQL database.

```bash
./backup/full_backup.sh
```

### 4. Perform Incremental Backup

Run the incremental backup script to create an incremental backup of your PostgreSQL database.

```bash
./backup/incremental_backup.sh
```

### 5. Schedule Automated Backups

Use the scheduling script to automate the backup process. This script uses `cron` for scheduling.

```bash
./backup/schedule_backups.sh
```

### 6. Upload Backups to AWS S3

Use the Python script to upload backups to AWS S3 for remote storage.

```bash
python3 s3/upload_to_s3.py
```

### 7. Restore from Backup

Use the restoration scripts to restore your PostgreSQL database from a full or incremental backup.

#### Restore Full Backup

```bash
./restore/restore_full_backup.sh /path/to/your/full_backup_file
```

#### Restore Incremental Backup

```bash
./restore/restore_incremental_backup.sh /path/to/your/incremental_backup_file
```

## Detailed Scripts and Explanations

### Full Backup Script (`full_backup.sh`)

This script performs a full backup of the PostgreSQL database.

```bash
#!/bin/bash

source ../config/backup_config.sh

TIMESTAMP=$(date +"%F")
BACKUP_FILE=$BACKUP_DIR/full_backup_$TIMESTAMP.sql

pg_dump -h $PG_HOST -p $PG_PORT -U $PG_USER -F c -b -v -f $BACKUP_FILE $PG_DATABASE

if [ $? -eq 0 ]; then
  echo "Full backup successful: $BACKUP_FILE" >> ../logs/backup.log
else
  echo "Full backup failed" >> ../logs/backup.log
fi
```

### Incremental Backup Script (`incremental_backup.sh`)

This script performs an incremental backup of the PostgreSQL database.

```bash
#!/bin/bash

source ../config/backup_config.sh

TIMESTAMP=$(date +"%F")
BACKUP_FILE=$BACKUP_DIR/incremental_backup_$TIMESTAMP.sql

pg_dump -h $PG_HOST -p $PG_PORT -U $PG_USER -F c -b -v -f $BACKUP_FILE -a -t $PG_DATABASE

if [ $? -eq 0 ]; then
  echo "Incremental backup successful: $BACKUP_FILE" >> ../logs/backup.log
else
  echo "Incremental backup failed" >> ../logs/backup.log
fi
```

### Scheduling Script (`schedule_backups.sh`)

This script sets up a `cron` job to schedule automated backups.

```bash
#!/bin/bash

# Add cron job for full backup at 2 AM every Sunday
(crontab -l 2>/dev/null; echo "0 2 * * 0 /path/to/backup/full_backup.sh") | crontab -

# Add cron job for incremental backup at 2 AM every day
(crontab -l 2>/dev/null; echo "0 2 * * * /path/to/backup/incremental_backup.sh") | crontab -

echo "Backup schedules added to cron."
```

### Upload to S3 Script (`upload_to_s3.py`)

This script uploads backup files to AWS S3.

```python
import boto3
import os
from config.aws_config import AWS_ACCESS_KEY, AWS_SECRET_KEY, S3_BUCKET_NAME, BACKUP_DIR

def upload_to_s3(file_name, bucket, object_name=None):
    if object_name is None:
        object_name = os.path.basename(file_name)
    
    s3_client = boto3.client('s3', aws_access_key_id=AWS_ACCESS_KEY, aws_secret_access_key=AWS_SECRET_KEY)
    try:
        s3_client.upload_file(file_name, bucket, object_name)
        print(f"Upload successful: {file_name} to {bucket}/{object_name}")
    except Exception as e:
        print(f"Upload failed: {e}")

if __name__ == "__main__":
    for backup_file in os.listdir(BACKUP_DIR):
        file_path = os.path.join(BACKUP_DIR, backup_file)
        upload_to_s3(file_path, S3_BUCKET_NAME)
```

### Restore Full Backup Script (`restore_full_backup.sh`)

This script restores a full backup of the PostgreSQL database.

```bash
#!/bin/bash

source ../config/backup_config.sh

if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/full_backup_file"
  exit 1
fi

BACKUP_FILE=$1

pg_restore -h $PG_HOST -p $PG_PORT -U $PG_USER -d $PG_DATABASE -v $BACKUP_FILE

if [ $? -eq 0 ]; then
  echo "Full backup restoration successful: $BACKUP_FILE" >> ../logs/restore.log
else
  echo "Full backup restoration failed" >> ../logs/restore.log
fi
```

### Restore Incremental Backup Script (`restore_incremental_backup.sh`)

This script restores an incremental backup of the PostgreSQL database.

```bash
#!/bin/bash

source ../config/backup_config.sh

if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/incremental_backup_file"
  exit 1
fi

BACKUP_FILE=$1

pg_restore -h $PG_HOST -p $PG_PORT -U $PG_USER -d $PG_DATABASE -v $BACKUP_FILE

if [ $? -eq 0 ]; then
  echo "Incremental backup restoration successful: $BACKUP_FILE" >> ../logs/restore.log
else
  echo "Incremental backup restoration failed" >> ../logs/restore.log
fi
```

## Contributing

We welcome contributions to improve this project. If you would like to contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch.
3. Make your changes.
4. Submit a pull request.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.

## Contact

For questions or issues, please open an issue in the repository or contact the project maintainers at [your-email@example.com].

---

Thank you for using our Automated Backup and Recovery System project! We hope this guide helps you set up a reliable backup and recovery solution for your PostgreSQL database.
