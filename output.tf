#
# IAM
#

# Role
output "aws-iam-role-lambda-arn" {
  value = local.on_common ? aws_iam_role.lambda[0].arn : ""
}

output "aws-iam-role-apprunner-arn" {
  value = local.on_common ? aws_iam_role.apprunner[0].arn : ""
}

#
# S3 bucket
#
output "aws-s3-lambda-bucket-arn" {
  value = local.on_common ? aws_s3_bucket.lambda-function[0].arn : ""
}

output "aws-s3-lambda-bucket-path" {
  value = local.on_common ? format("%s/%s", aws_s3_bucket.lambda-function[0].bucket, local.lambda_path) : ""
}

#
# Lambda function
#
output "aws-lambda-function-handler" {
  value = local.on_system ? aws_lambda_function.hello[0].handler : ""
}

#
# apigateway url
#
output "deployment-invoke-url" {
  value = local.on_system ? aws_api_gateway_deployment.api-deploy[0].invoke_url : ""
}

#
# ECR URL
#
output "ecr-url" {
  value = local.on_system ? aws_ecr_repository.sample-app[0].repository_url : ""
}

#
# App runner url
#
output "apprunner-url" {
  value = local.on_service ? aws_apprunner_service.sample-app[0].service_url : ""
}