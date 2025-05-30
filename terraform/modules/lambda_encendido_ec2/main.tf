resource "aws_lambda_function" "lambda_encendido_ec2" {
  function_name    = "lambda_encendido_ec2"
  runtime         = "python3.9"
  role            = var.labrole_arn
  handler         = "lambda_function.lambda_handler"
  filename        = "${path.module}/lambda_encendido_ec2.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_encendido_ec2.zip")

  environment {
    variables = {
      EC2_INSTANCE_ID = var.ec2_instance_id
    }
  }
}


# Obtener el ID de cuenta de AWS Learner Lab
data "aws_caller_identity" "current" {}

output "lambda_encendido_ec2_arn" {
  description = "ARN de la función Lambda que enciende la EC2"
  value       = aws_lambda_function.lambda_encendido_ec2.arn
}

output "lambda_encendido_ec2_name" {
  description = "Nombre de la función Lambda que enciende la EC2"
  value       = aws_lambda_function.lambda_encendido_ec2.function_name
}