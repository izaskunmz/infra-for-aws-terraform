#!/bin/bash

# Nombre del bucket
BUCKET_NAME=$(aws s3 ls | grep videos | awk '{print $3}')
VIDEO_DIR="/home/ubuntu/detection-model/data/videos"
RESULT_DIR="/home/ubuntu/detection-model/data/videos_procesados"
RESULT_FILE="resultados.json"

# Crear carpeta para almacenar videos y asignar permisos adecuados
mkdir -p "$VIDEO_DIR"
chown ubuntu:ubuntu "$VIDEO_DIR"

echo "📂 Carpeta creada con éxito: $VIDEO_DIR"

# Crear carpeta para almacenar videos procesados y asignar permisos adecuados
mkdir -p "$RESULT_FILE"
chown ubuntu:ubuntu "$RESULT_FILE"

echo "📂 Carpeta creada con éxito: $RESULT_FILE"

# Listar archivos en el bucket y obtener el más reciente
LATEST_FILE=$(aws s3 ls s3://$BUCKET_NAME/ --recursive | sort | tail -n 1 | awk '{print $4}')

# Verificar si hay archivos en S3
if [ -z "$LATEST_FILE" ]; then
    echo "❌ No se encontró ningún archivo en el bucket S3."
    exit 1
fi

# Descargar el archivo más reciente a la carpeta de videos
aws s3 cp s3://$BUCKET_NAME/$LATEST_FILE "$VIDEO_DIR/"

# Verificar si la descarga fue exitosa antes de eliminarlo de S3
if [ $? -eq 0 ]; then
    echo "✅ Descarga completada exitosamente: $LATEST_FILE"
    aws s3 rm s3://$BUCKET_NAME/$LATEST_FILE
    echo "🗑️ Video eliminado de S3: $LATEST_FILE"
else
    echo "❌ Error en la descarga del video."
    exit 1
fi

# Activar entorno virtual
source /home/ubuntu/venv/bin/activate

# Ejecutar el modelo de detección facial
cd /home/ubuntu/detection-model
python3.9 main.py

# Verificar si se generó el archivo de resultados
if [ ! -f "$RESULT_DIR/$RESULT_FILE" ]; then
    echo "❌ Error: El archivo de resultados no se generó."
    exit 1
fi

# Subir el archivo de resultados a S3 en la carpeta /results/
RESULT_S3_PATH="s3://$BUCKET_NAME/results/results_${LATEST_FILE%.*}.json"
aws s3 cp "$RESULT_DIR/$RESULT_FILE" "$RESULT_S3_PATH"

echo "✅ Resultados subidos a S3: $RESULT_S3_PATH"

# Ejecutar script de subida a DynamoDB
python3.9 /home/ubuntu/scripts/subida_a_dynamo.py