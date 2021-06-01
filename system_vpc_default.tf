locals {
  vpc_flow_log_log_group_advanced = "${local.vpc_flow_log_group_prefix}advanced"
}

resource "aws_default_vpc" "advanced" {
  count = local.on_system ? 1 : 0

  tags = {
    Name = "Default"
  }
}

resource "aws_cloudwatch_log_group" "vpc-flow-log-advanced" {
  count = local.on_system ? 1 : 0

  name = local.vpc_flow_log_log_group_advanced
  retention_in_days = 7
}

resource "aws_flow_log" "advanced" {
  count = local.on_system ? 1 : 0

  vpc_id               = aws_default_vpc.advanced[0].id
  iam_role_arn         = data.terraform_remote_state.common.outputs.aws_iam_role_vpc_flow_log_arn
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc-flow-log-advanced[0].arn
  traffic_type         = local.vpc_flow_log_traffic_type
}

resource "aws_default_security_group" "advanced" {
  count = local.on_system ? 1 : 0

  vpc_id = aws_default_vpc.advanced[0].id

  tags = {
    Name = "Default advanced"
  }
}

resource "aws_default_security_group" "default" {
  count = local.on_network ? 1 : 0

  vpc_id = aws_vpc.default[0].id

  tags = {
    Name    = format("Default %s %s", local.service_name, local.env)
    service = local.service_name
    env     = local.env
  }
}

