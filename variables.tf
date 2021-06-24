#
# Account
#
locals {
  # just change this value to a custom one
  service_name = "workshop"
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
  lambda_bucket        = "drecom-terraform-workshop"
  lambda_path          = format("%s-%s", local.service_name, "lambda")
  lambda_key           = "${local.lambda_path}/lambda.zip"
  lambda_main_key      = "${local.lambda_path}/lambda-main.zip"
  lambda_lib_key       = "${local.lambda_path}/lambda-lib.zip"
  lambda_runtime       = "python3.6"
  lambda_function_name = "hello"
}

locals {
  lambda_log_group_prefix = "/aws/lambda/"
}

#
# Api gateway
#
locals {
  api_gateway_rest_api_name     = "hello"
  api_gateway_deploy_stage_name = "example"
}

#
# App runner
#
locals {
  apprunner_service_name = "sample-app"
  apprunner_service_port = "3000"
  ecr_repo_tag           = "release"
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