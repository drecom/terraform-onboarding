data "aws_s3_bucket_object" "lambda" {
  count = local.on_system ? 1 : 0

  bucket = local.lambda_bucket
  key    = local.lambda_key
}

data "aws_s3_bucket_object" "lambda-main" {
  count = local.on_system ? 1 : 0

  bucket = local.lambda_bucket
  key    = local.lambda_main_key
}

data "aws_s3_bucket_object" "lambda-lib" {
  count = local.on_system ? 1 : 0

  bucket = local.lambda_bucket
  key    = local.lambda_lib_key
}

