#
# sshguard解除のセルフサービス用
#
resource "aws_api_gateway_rest_api" "hello-drecom" {
  count = local.on_system ? 1 : 0

  name = "hello-drecom"
}

resource "aws_api_gateway_resource" "proxy" {
  count = local.on_system ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.hello-drecom[0].id
  parent_id   = aws_api_gateway_rest_api.hello-drecom[0].root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxyMethod" {
  count = local.on_system ? 1 : 0

  rest_api_id   = aws_api_gateway_rest_api.hello-drecom[0].id
  resource_id   = aws_api_gateway_resource.proxy[0].id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello-drecom" {
  count = local.on_system ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.hello-drecom[0].id
  resource_id = aws_api_gateway_method.proxyMethod[0].resource_id
  http_method = aws_api_gateway_method.proxyMethod[0].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello-drecom[0].invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  count = local.on_system ? 1 : 0

  rest_api_id   = aws_api_gateway_rest_api.hello-drecom[0].id
  resource_id   = aws_api_gateway_rest_api.hello-drecom[0].root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  count = local.on_system ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.hello-drecom[0].id
  resource_id = aws_api_gateway_method.proxy_root[0].resource_id
  http_method = aws_api_gateway_method.proxy_root[0].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello-drecom[0].invoke_arn
}


resource "aws_api_gateway_deployment" "apideploy" {
  count = local.on_system ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.hello-drecom[0].id
  stage_name  = "test"

  depends_on = [
    aws_api_gateway_integration.hello-drecom,
    aws_api_gateway_integration.lambda_root,
  ]
}
