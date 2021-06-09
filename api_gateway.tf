#
# sample lambda function's trigger (api-gateway)
#
resource "aws_api_gateway_rest_api" "hello" {
  count = local.on_system ? 1 : 0

  name = format("%s-%s", local.service_name, local.api_gateway_rest_api_name)
}

resource "aws_api_gateway_resource" "proxy" {
  count = local.on_system ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.hello[0].id
  parent_id   = aws_api_gateway_rest_api.hello[0].root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy-method" {
  count = local.on_system ? 1 : 0

  rest_api_id   = aws_api_gateway_rest_api.hello[0].id
  resource_id   = aws_api_gateway_resource.proxy[0].id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello" {
  count = local.on_system ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.hello[0].id
  resource_id = aws_api_gateway_method.proxy-method[0].resource_id
  http_method = aws_api_gateway_method.proxy-method[0].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello[0].invoke_arn
}

resource "aws_api_gateway_method" "proxy-root" {
  count = local.on_system ? 1 : 0

  rest_api_id   = aws_api_gateway_rest_api.hello[0].id
  resource_id   = aws_api_gateway_rest_api.hello[0].root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda-root" {
  count = local.on_system ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.hello[0].id
  resource_id = aws_api_gateway_method.proxy-root[0].resource_id
  http_method = aws_api_gateway_method.proxy-root[0].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello[0].invoke_arn
}


resource "aws_api_gateway_deployment" "api-deploy" {
  count = local.on_system ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.hello[0].id
  stage_name  = format("%s-%s", local.service_name, local.api_gateway_deploy_stage_name)

  depends_on = [
    aws_api_gateway_integration.hello,
    aws_api_gateway_integration.lambda-root,
  ]
}
