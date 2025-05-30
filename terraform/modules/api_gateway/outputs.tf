output "api_gateway_endpoint" {
  description = "URL base del API Gateway"
  value       = aws_apigatewayv2_stage.api_stage.invoke_url
}