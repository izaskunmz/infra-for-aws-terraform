variable "ec2_instance_id" {
  description = "ID de la instancia EC2 que la Lambda debe encender"
  type        = string
}

variable "labrole_arn" {
  description = "ARN del rol LabRole"
  type        = string
}