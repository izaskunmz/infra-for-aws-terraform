import boto3
import os

s3_client = boto3.client("s3")
bucket_name = os.environ["RAW_BUCKET_NAME"]  # Bucket de S3

def lambda_handler(event, context):
    try:
        # Obtener el nombre del archivo desde la URL de la API
        filename = event["pathParameters"]["filename"]

        # Leer el archivo binario desde el body
        file_content = event["body"]

        # Si el body está en base64 (por API Gateway), hay que decodificarlo
        if event["isBase64Encoded"]:
            import base64
            file_content = base64.b64decode(file_content)

        # Subir el archivo a S3 en la carpeta "videos/"
        s3_client.put_object(
            Bucket=bucket_name,
            Key=f"videos/{filename}",
            Body=file_content,
            ContentType="video/mp4"  # Definir el tipo de archivo correctamente
        )

        return {
            "statusCode": 200,
            "body": f"Archivo {filename} subido correctamente a {bucket_name}"
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": f"Error subiendo archivo: {str(e)}"
        }
