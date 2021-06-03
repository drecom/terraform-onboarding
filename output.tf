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
# VPC
#
#output "aws_vpc_default_id" {
#  value = local.on_network ? aws_vpc.default[0].id : ""
#}
#
#output "aws_subnet_private_ids" {
#  value = local.on_network ? aws_subnet.private[0].id : ""
#}
#
#output "aws_route_table_private_nat_id" {
#  value = local.on_system ? aws_route_table.private_nat[0].id : ""
#}
#
##
## EC2
##
#output "aws_key_pair_admin_key_name" {
#  value = local.on_system ? aws_key_pair.admin[0].key_name : ""
#}
#
##
## RDS
##
#output "aws_rds_cluster_parameter_group_aurora_name" {
#  value = local.on_system ? aws_rds_cluster_parameter_group.aurora[0].name : ""
#}
#
#output "aws_db_parameter_group_aurora_name" {
#  value = local.on_system ? aws_db_parameter_group.aurora[0].name : ""
#}
#
#output "aws_db_parameter_group_mysql_name" {
#  value = local.on_system ? aws_db_parameter_group.mysql[0].name : ""
#}

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