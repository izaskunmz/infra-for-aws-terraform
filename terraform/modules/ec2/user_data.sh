#!/bin/bash
set -e
exec > /var/log/user_data.log 2>&1

echo "Iniciando configuración de la EC2..."

sudo apt update -y && sudo apt upgrade -y
sudo apt install -y build-essential libssl-dev libffi-dev \
  zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev cmake python3-pip git unzip awscli jq

# Crear carpeta de scripts
mkdir -p /home/ubuntu/scripts
sudo chown ubuntu:ubuntu /home/ubuntu/scripts

# Esperar hasta que los archivos sean subidos (hasta 5 minutos)
echo "Esperando a que los archivos sean subidos a /home/ubuntu/scripts/..."
MAX_WAIT=300  # 300 segundos (5 minutos)
CHECK_INTERVAL=5
ELAPSED_TIME=0

while [ ! -f "/home/ubuntu/scripts/requirements.txt" ]; do
    if [ "$ELAPSED_TIME" -ge "$MAX_WAIT" ]; then
        echo "❌ ERROR: No se encontraron archivos en /home/ubuntu/scripts/ después de 5 minutos."
        exit 1
    fi
    echo "Archivos aún no están disponibles, esperando..."
    sleep $CHECK_INTERVAL
    ELAPSED_TIME=$((ELAPSED_TIME + CHECK_INTERVAL))
done

echo "Archivos encontrados. Continuando con la configuración."

# Verificar si los archivos se descargaron correctamente
if [ ! -f "/home/ubuntu/scripts/requirements.txt" ]; then
    echo "ERROR: No se pudo descargar el archivo requirements.txt"
    exit 1
fi

# Dar permisos de ejecución a los scripts
chmod +x /home/ubuntu/scripts/*.sh
cd /usr/src
sudo wget https://www.python.org/ftp/python/3.9.21/Python-3.9.21.tgz
sudo tar xvf Python-3.9.21.tgz
cd Python-3.9.21
sudo ./configure --enable-optimizations
sudo make -j$(nproc)
sudo make altinstall
python3.9 --version

# Clonar el repositorio de GitLab
echo "Clonando repositorio detection-model..."
git clone --depth 1 https://gitlab.com/iabd2425grupo3/detection-model.git /home/ubuntu/detection-model

# Cambiar permisos de la carpeta
chown -R ubuntu:ubuntu /home/ubuntu/detection-model

echo "Repositorio clonado exitosamente."

cd /home/ubuntu/detection-model
python3.9 -m venv venv
source venv/bin/activate

# Instalar dependencias
echo "Instalando dependencias de requirements.txt..."
pip install --upgrade pip
pip install -r /home/ubuntu/scripts/requirements.txt

# Agregar script_master.sh al crontab para que se ejecute al reiniciar
echo "Configurando crontab..."
CRON_JOB="@reboot ubuntu /home/ubuntu/scripts/script_master.sh"
(crontab -u ubuntu -l 2>/dev/null; echo "$CRON_JOB") | sort -u | crontab -u ubuntu -

# Dar permisos correctos a crontab
sudo chmod 600 /var/spool/cron/crontabs/ubuntu

echo "✅ Configuración de la EC2 completada."
