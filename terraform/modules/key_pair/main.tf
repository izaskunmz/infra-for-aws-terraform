# Generar un par de claves SSH
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Guardar la clave en un archivo local
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/ec2-key.pem"
  file_permission = "0400"  # Permisos adecuados para SSH
}

# Crear el par de claves en AWS
resource "aws_key_pair" "ssh_key" {
  key_name   = "ec2-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Output del nombre de la clave
output "key_name" {
  description = "Nombre del par de claves SSH"
  value       = aws_key_pair.ssh_key.key_name
}

