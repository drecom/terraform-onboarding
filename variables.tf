#
# Account
#
locals {
  # no need to change
  service_name = "workshop"

  # no need to change
  company_name = "drecom"
}

#
# Variables for determining resource needs for each environment
#    - common  : for commonly used resources
#    - system  : for those resources which outside the service
#    - service : for production service resources
locals {
  env        = terraform.workspace
  on_common  = local.env == "common" ? true : false
  on_system  = local.env == "system" ? true : false
  on_service = local.env != "common" && local.env != "system" ? true : false
}

#
# Lambda
#
locals {
  lambda_bucket   = "drecom-lambda"
  lambda_key      = "lambda.zip"
  lambda_main_key = "lambda_main.zip"
  lambda_lib_key  = "lambda_lib.zip"
  lambda_runtime  = "python3.6"
}

locals {
  lambda_log_group_prefix = "/aws/lambda/"
}

#
# Api gateway
#
locals {
  api_gateway_rest_api_name = "hello-drecom"
  api_gateway_deploy_stage_name = "drecom"
}

#
# App runner
#
locals {
  apprunner_service_name   = "sample-app"
  apprunner_service_port   = "3000"
  ecr_repo_tag             = "release"
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "service_account_id" {
  type = string
}

variable "region" {
  type = string
}