resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Crear el bucket para datos en bruto
resource "aws_s3_bucket" "raw_data" {
  bucket = "data-raw-deepray-${random_string.suffix.result}"
}

# Crear carpeta /videos dentro del bucket data-raw-deepray
resource "aws_s3_object" "videos_folder" {
  bucket       = aws_s3_bucket.raw_data.id
  key          = "videos/"
  content_type = "application/x-directory"
}

# Configurar propiedad del bucket
resource "aws_s3_bucket_ownership_controls" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Crear el bucket para datos procesados
resource "aws_s3_bucket" "processed_data" {
  bucket = "data-processed-deepray-${random_string.suffix.result}"
}

# Configurar propiedad del bucket
resource "aws_s3_bucket_ownership_controls" "processed_data" {
  bucket = aws_s3_bucket.processed_data.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Crear carpeta /results dentro del bucket data-processed-deepray
resource "aws_s3_object" "results_folder" {
  bucket       = aws_s3_bucket.processed_data.id
  key          = "results/"
  content_type = "application/x-directory"
}

# Crear carpeta /logs dentro del bucket data-processed-deepray
resource "aws_s3_object" "logs_folder" {
  bucket       = aws_s3_bucket.processed_data.id
  key          = "logs/"
  content_type = "application/x-directory"
}

output "processed_bucket_name" {
  description = "Nombre del bucket para datos procesados"
  value       = aws_s3_bucket.processed_data.id
}

output "raw_bucket_name" {
  description = "Nombre del bucket para datos en bruto"
  value       = aws_s3_bucket.raw_data.id
}