resource "aws_lambda_function" "lambda_upload_s3" {
  function_name    = "lambda-upload-s3"
  runtime         = "python3.9"
  handler         = "lambda_function.lambda_handler"
  filename        = "${path.module}/lambda_upload_s3.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_upload_s3.zip")
  role            = var.labrole_arn
  timeout         = 30

  environment {
    variables = {
      RAW_BUCKET_NAME = var.raw_bucket_name
    }
  }
}