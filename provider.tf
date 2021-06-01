provider "aws" {
  region     = local.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  allowed_account_ids = [local.service_account_id]
}
