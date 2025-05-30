output "lambda_arn" {
  description = "ARN de la Lambda que devuelve resultados desde S3"
  value       = aws_lambda_function.lambda_results_s3_to_api.arn
}

output "lambda_name" {
  description = "Nombre de la función Lambda que devuelve resultados desde S3"
  value       = aws_lambda_function.lambda_results_s3_to_api.function_name
}