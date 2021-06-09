provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  allowed_account_ids = [var.service_account_id]

  default_tags {
    tags = {
      Name = "${service_name}-${local.env}"
    }
  }
}
