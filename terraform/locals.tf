data "aws_caller_identity" "current" {}

locals {
  labrole_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
}