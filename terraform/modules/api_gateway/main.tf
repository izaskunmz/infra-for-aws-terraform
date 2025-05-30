resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "api-reto2"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  name        = "v4"
  auto_deploy = true
}

# 🔹 GET `/get-video` - Obtiene los resultados desde S3
resource "aws_apigatewayv2_route" "get_video" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "GET /get-video"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_results.id}"
}

resource "aws_apigatewayv2_integration" "lambda_results" {
  api_id           = aws_apigatewayv2_api.api_gateway.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_results_arn
}

resource "aws_lambda_permission" "apigw_lambda_results" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_results_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
}

# 🔹 PUT `/bucket/folder/filename` - Genera URL prefirmada para subir video
resource "aws_apigatewayv2_route" "upload_video" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "PUT /{bucket}/{folder}/{filename}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_upload.id}"
}

resource "aws_apigatewayv2_integration" "lambda_upload" {
  api_id           = aws_apigatewayv2_api.api_gateway.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_upload_arn
}

resource "aws_lambda_permission" "apigw_lambda_upload" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_upload_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
}