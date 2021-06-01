resource "aws_lambda_layer_version" "system-lib" {
  count = local.on_system ? 1 : 0

  layer_name        = "system-lib"
  s3_bucket         = local.lambda_bucket
  s3_key            = local.lambda_lib_key
  s3_object_version = data.aws_s3_bucket_object.lambda_lib[0].version_id

  compatible_runtimes = [local.lambda_runtime]
}

