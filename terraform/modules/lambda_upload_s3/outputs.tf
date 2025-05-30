output "lambda_upload_arn" {
  description = "ARN de la Lambda para subir archivos a S3"
  value       = aws_lambda_function.lambda_upload_s3.arn
}

output "lambda_upload_name" {
  description = "Nombre de la Lambda para subir archivos a S3"
  value       = aws_lambda_function.lambda_upload_s3.function_name
}
