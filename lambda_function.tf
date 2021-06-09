#
# sample lambda function
#
resource "aws_lambda_function" "hello" {
  count = local.on_system ? 1 : 0

  function_name     = format("%s-%s", local.service_name, local.lambda_function_name)
  handler           = "${local.lambda_function_name}.lambda_handler"
  s3_bucket         = local.lambda_bucket
  s3_key            = local.lambda_main_key
  s3_object_version = data.aws_s3_bucket_object.lambda-main[0].version_id

  layers = [aws_lambda_layer_version.system-lib[0].arn]

  memory_size = 128
  timeout     = 3

  runtime = local.lambda_runtime
  role    = data.terraform_remote_state.common.outputs.aws-iam-role-lambda-arn
}

resource "aws_cloudwatch_log_group" "hello" {
  count = local.on_system ? 1 : 0

  name              = format("%s%s", local.lambda_log_group_prefix, local.lambda_function_name)
  retention_in_days = 1
}

resource "aws_lambda_permission" "hello" {
  count = local.on_system ? 1 : 0

  function_name = aws_lambda_function.hello[0].arn
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"

  source_arn = "${aws_api_gateway_rest_api.hello[0].execution_arn}/*/*"
}
