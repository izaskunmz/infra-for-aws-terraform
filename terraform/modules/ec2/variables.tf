variable "key_name" {
  description = "Nombre de la clave SSH utilizada para la EC2"
  type        = string
}

variable "security_group_id" {
  description = "ID del Security Group asignado a la EC2"
  type        = string
}

variable "processed_bucket" {
  description = "Nombre del bucket de datos procesados en S3"
  type        = string
}

