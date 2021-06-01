#
# sshguard解除のセルフサービス用
#
locals {
  ip_tables_chain_path = "/tmp"
  target_instance_name = "gitlab-web-10x128x7x197"
  ban_ip_pool = format("%s/%s.txt", local.ip_tables_chain_path, local.target_instance_name)
  s3_bucket_name = "drecom-sshguard-ban-list"
  tag_key = "tag:bot"
  tag_value = "release-sshguard"
}
resource "aws_api_gateway_rest_api" "release-sshguard" {
  count = local.on_system ? 1 : 0

  name = "release-sshguard"
}

resource "aws_api_gateway_resource" "proxy" {
  count = local.on_system ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.release-sshguard[0].id
  parent_id   = aws_api_gateway_rest_api.release-sshguard[0].root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxyMethod" {
  count = local.on_system ? 1 : 0

  rest_api_id   = aws_api_gateway_rest_api.release-sshguard[0].id
  resource_id   = aws_api_gateway_resource.proxy[0].id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "release-sshguard" {
  count = local.on_system ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.release-sshguard[0].id
  resource_id = aws_api_gateway_method.proxyMethod[0].resource_id
  http_method = aws_api_gateway_method.proxyMethod[0].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.release-sshguard[0].invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  count = local.on_system ? 1 : 0

  rest_api_id   = aws_api_gateway_rest_api.release-sshguard[0].id
  resource_id   = aws_api_gateway_rest_api.release-sshguard[0].root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  count = local.on_system ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.release-sshguard[0].id
  resource_id = aws_api_gateway_method.proxy_root[0].resource_id
  http_method = aws_api_gateway_method.proxy_root[0].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.release-sshguard[0].invoke_arn
}


resource "aws_api_gateway_deployment" "apideploy" {
  count = local.on_system ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.release-sshguard[0].id
  stage_name  = "test"

  depends_on = [
    aws_api_gateway_integration.release-sshguard,
    aws_api_gateway_integration.lambda_root,
  ]
}

resource "aws_lambda_function" "release-sshguard" {
  count = local.on_system ? 1 : 0

  function_name     = "release-sshguard"
  handler           = "release-sshguard.lambda_handler"
  s3_bucket         = local.lambda_bucket
  s3_key            = local.lambda_main_key
  s3_object_version = data.aws_s3_bucket_object.lambda_main[0].version_id

  layers = [aws_lambda_layer_version.system-lib[0].arn]

  memory_size = 512
  timeout     = 3

  runtime = local.lambda_runtime
  role    = "arn:aws:iam::596431367989:role/lambda_basic_vpc_execution"

  environment {
    variables = {
      ec2_tag_key = local.tag_key
      ec2_tag_value = local.tag_value
      ban_list_s3_bucket_name = local.s3_bucket_name
      ec2_hostname = local.target_instance_name
    }
  }
}

resource "aws_cloudwatch_log_group" "release-sshguard" {
  count = local.on_system ? 1 : 0

  name              = format("%s%s", local.lambda_log_group_prefix, "release-sshguard")
  retention_in_days = 7
}

resource "aws_lambda_permission" "release-sshguard" {
  count = local.on_system ? 1 : 0

  function_name = aws_lambda_function.release-sshguard[0].arn
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"

  source_arn = "${aws_api_gateway_rest_api.release-sshguard[0].execution_arn}/*/*"
}


#
# update ban ip list via cloudwatch event
#
resource "aws_iam_role" "update-sshguard-ban-ip" {
  count = local.on_system ? 1 : 0
  
  name = "update-sshguard-ban-ip"
  assume_role_policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "events.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
EOF
}