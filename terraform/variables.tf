variable "region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type        = string
  default     = "us-east-1"
}

variable "labrole_arn" {
  description = "ARN del rol LabRole"
  type        = string
}
