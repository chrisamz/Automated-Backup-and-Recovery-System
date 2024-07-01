import boto3
import os
import sys
from botocore.exceptions import NoCredentialsError
from config.aws_config import AWS_ACCESS_KEY, AWS_SECRET_KEY, S3_BUCKET_NAME, BACKUP_DIR

def download_from_s3(object_name, bucket, file_name=None):
    """
    Download a file from an S3 bucket

    :param object_name: S3 object name to download
    :param bucket: Bucket to download from
    :param file_name: File name to save the downloaded file as. If not specified then object_name is used
    :return: True if file was downloaded, else False
    """
    if file_name is None:
        file_name = os.path.join(BACKUP_DIR, os.path.basename(object_name))

    s3_client = boto3.client('s3', aws_access_key_id=AWS_ACCESS_KEY, aws_secret_access_key=AWS_SECRET_KEY)
    try:
        s3_client.download_file(bucket, object_name, file_name)
        print(f"Download successful: {object_name} from {bucket} to {file_name}")
        return True
    except FileNotFoundError:
        print(f"The file was not found: {file_name}")
        return False
    except NoCredentialsError:
        print("Credentials not available")
        return False
    except Exception as e:
        print(f"Download failed: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 download_from_s3.py s3_object_name")
        sys.exit(1)

    s3_object_name = sys.argv[1]

    success = download_from_s3(s3_object_name, S3_BUCKET_NAME)
    if not success:
        sys.exit(1)
