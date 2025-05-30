import boto3
import json
import os

# Obtener el nombre del bucket desde variables de entorno
bucket = os.getenv('PROCESSED_BUCKET')
carpeta = "results/"

def get_latest_file(bucket, prefix):
    s3 = boto3.client("s3")

    response = s3.list_objects_v2(Bucket=bucket, Prefix=carpeta)

    # Si no hay archivos en la carpeta, retornar None
    if "Contents" not in response:
        return None

    # Obtener el archivo más reciente por fecha de modificación
    latest_file = max(response["Contents"], key=lambda obj: obj["LastModified"])

    return latest_file["Key"]

def get_file_content(bucket, file_key):
    s3 = boto3.client("s3")

    # Descargar el archivo desde S3
    response = s3.get_object(Bucket=bucket, Key=file_key)

    # Leer el contenido del archivo
    file_content = response["Body"].read().decode("utf-8")

    # Convertir a JSON
    json_data = json.loads(file_content)
    
    return json_data

def lambda_handler(event, context):
    latest_file = get_latest_file(bucket, carpeta)

    if not latest_file:
        return {
            "statusCode": 404,
            "body": json.dumps({"error": "No hay archivos en la carpeta results/."})
        }

    # Obtener contenido del JSON
    json_data = get_file_content(bucket, latest_file)

    return {
        "statusCode": 200,
        "body": json.dumps(json_data),
        "headers": {
            "Content-Type": "application/json"
        }
    }