#!/bin/bash

# Desplegar la infraestructura con Terraform
terraform init
terraform plan
terraform apply -auto-approve

# Obtener la IP pública de la EC2
EC2_IP=$(terraform output -raw ec2_public_ip)

# Esperar unos segundos para que la EC2 esté lista
echo "Esperando 160 segundos para que la EC2 esté lista..."
sleep 160

# Subir los scripts usando SCP
echo "Subiendo scripts a la EC2..."
scp -i /home/izaskunmz/terraform-projects/infraestructuraaws/terraform/modules/key_pair/ec2-key.pem -r ./scripts ubuntu@$EC2_IP:/home/ubuntu/

# Conectar a la EC2 para verificar que los archivos están ahí
echo "Archivos subidos. Verificando en la EC2..."
ssh -i /home/izaskunmz/terraform-projects/infraestructuraaws/terraform/modules/key_pair/ec2-key.pem ubuntu@$EC2_IP "ls -l /home/ubuntu/scripts"
