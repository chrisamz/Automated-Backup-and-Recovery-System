import boto3
import os
import sys
from botocore.exceptions import NoCredentialsError
from config.aws_config import AWS_ACCESS_KEY, AWS_SECRET_KEY, S3_BUCKET_NAME, BACKUP_DIR

def upload_to_s3(file_name, bucket, object_name=None):
    """
    Upload a file to an S3 bucket

    :param file_name: File to upload
    :param bucket: Bucket to upload to
    :param object_name: S3 object name. If not specified then file_name is used
    :return: True if file was uploaded, else False
    """
    if object_name is None:
        object_name = os.path.basename(file_name)

    s3_client = boto3.client('s3', aws_access_key_id=AWS_ACCESS_KEY, aws_secret_access_key=AWS_SECRET_KEY)
    try:
        s3_client.upload_file(file_name, bucket, object_name)
        print(f"Upload successful: {file_name} to {bucket}/{object_name}")
        return True
    except FileNotFoundError:
        print(f"The file was not found: {file_name}")
        return False
    except NoCredentialsError:
        print("Credentials not available")
        return False
    except Exception as e:
        print(f"Upload failed: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 upload_to_s3.py /path/to/backup_file")
        sys.exit(1)

    backup_file_path = sys.argv[1]

    # Check if the backup file exists
    if not os.path.isfile(backup_file_path):
        print(f"Backup file not found: {backup_file_path}")
        sys.exit(1)

    success = upload_to_s3(backup_file_path, S3_BUCKET_NAME)
    if not success:
        sys.exit(1)
