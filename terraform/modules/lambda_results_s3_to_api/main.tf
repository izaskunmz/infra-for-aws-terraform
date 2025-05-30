resource "aws_lambda_function" "lambda_results_s3_to_api" {
  function_name    = "lambda_results_s3_to_api"
  runtime         = "python3.9"
  role            = var.labrole_arn
  handler         = "lambda_function.lambda_handler"
  filename        = "${path.module}/lambda_results_s3_to_api.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_results_s3_to_api.zip")
  timeout         = 30
  
  environment {
    variables = {
      PROCESSED_BUCKET = var.processed_bucket
    }
  }
}

# Obtener el ID de cuenta de AWS Learner Lab
data "aws_caller_identity" "current" {}

output "lambda_results_s3_to_api_arn" {
  description = "ARN de la función Lambda que devuelve los resultados desde S3"
  value       = aws_lambda_function.lambda_results_s3_to_api.arn
}

output "lambda_results_s3_to_api_name" {
  description = "Nombre de la función Lambda que devuelve los resultados desde S3"
  value       = aws_lambda_function.lambda_results_s3_to_api.function_name
}