module "s3" {
  source = "./modules/s3"
}

module "security" {
  source = "./modules/security"
}

module "key_pair" {
  source = "./modules/key_pair"
}

module "ec2" {
  source             = "./modules/ec2"
  security_group_id  = module.security.security_group_id
  key_name           = module.key_pair.key_name
  processed_bucket   = module.s3.processed_bucket_name 
}

module "lambda_encendido_ec2" {
  source         = "./modules/lambda_encendido_ec2"
  labrole_arn    = local.labrole_arn  # Usa el local en lugar de la variable
  ec2_instance_id = module.ec2.instance_id
}

module "lambda_results_s3_to_api" {
  source          = "./modules/lambda_results_s3_to_api"
  labrole_arn     = local.labrole_arn  # Usa el local en lugar de la variable
  processed_bucket = module.s3.processed_bucket_name
}

module "lambda_upload_s3" {
  source          = "./modules/lambda_upload_s3"
  raw_bucket_name = module.s3.raw_bucket_name
  labrole_arn     = local.labrole_arn
}

module "api_gateway" {
  source             = "./modules/api_gateway"
  region             = var.region
  raw_bucket_name    = module.s3.raw_bucket_name
  lambda_upload_arn  = module.lambda_upload_s3.lambda_upload_arn
  lambda_upload_name = module.lambda_upload_s3.lambda_upload_name
  lambda_results_arn = module.lambda_results_s3_to_api.lambda_results_s3_to_api_arn
  lambda_results_name = module.lambda_results_s3_to_api.lambda_results_s3_to_api_name
  labrole_arn        = local.labrole_arn
}

module "dynamodb" {
  source = "./modules/dynamodb"
}
