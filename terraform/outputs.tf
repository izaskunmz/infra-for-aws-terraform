output "ec2_public_ip" {
  description = "Dirección IP pública de la instancia EC2"
  value       = module.ec2.ec2_public_ip
}

output "key_name" {
  description = "Nombre del par de claves SSH"
  value       = module.key_pair.key_name
}

output "processed_bucket_name" {
  description = "Nombre del bucket para datos procesados"
  value       = module.s3.processed_bucket_name
}

output "raw_bucket_name" {
  description = "Nombre del bucket para datos en bruto"
  value       = module.s3.raw_bucket_name
}

output "security_group_id" {
  description = "ID del Security Group de la EC2"
  value       = module.security.security_group_id
}

output "api_gateway_url" {
  description = "URL de la API Gateway desplegada"
  value       = module.api_gateway.api_gateway_endpoint
}
