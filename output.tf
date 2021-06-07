#
# IAM
#

# Role
output "aws_iam_role_lambda_arn" {
  value = local.on_common ? aws_iam_role.lambda[0].arn : ""
}

output "aws_iam_role_apprunner_arn" {
  value = local.on_common ? aws_iam_role.apprunner[0].arn : ""
}

#
# S3 bucket
#
output "aws_s3_lambda_bucket_arn" {
  value = local.on_common ? aws_s3_bucket.lambda_function[0].arn : ""
}

#
# apigateway url
#
output "deployment_invoke_url" {
  value = local.on_system ? aws_api_gateway_deployment.apideploy[0].invoke_url : ""
}

#
# ECR URL
#
output "ecr_url" {
  value = local.on_system ? aws_ecr_repository.sample-app[0].repository_url : ""
}

#
# App runner url
#
output "app_runner_url" {
  value = local.on_service ? aws_apprunner_service.sample-app[0].service_url : ""
}