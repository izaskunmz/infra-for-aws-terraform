#!/bin/bash

# Configurar el log con fecha y hora
LOG_FILE="/home/ubuntu/logs/salida_$(date '+%Y-%m-%d_%H-%M-%S').log"
mkdir -p /home/ubuntu/logs

# Nombre del bucket donde se guardarán los logs
BUCKET_PROCESSED=$(aws s3 ls | grep processed | awk '{print $3}')

# Activar el entorno virtual
source /home/ubuntu/venv/bin/activate

# Ejecutar el script principal y guardar logs
./script.sh 2>&1 | tee "$LOG_FILE"

# Subir logs a S3
aws s3 cp "$LOG_FILE" s3://$BUCKET_PROCESSED/logs/
