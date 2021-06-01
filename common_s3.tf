#
# lambda function
#
resource "aws_s3_bucket" "lambda_function" {
  count = local.on_common ? 1 : 0

  bucket = local.lambda_bucket
  acl    = "log-delivery-write"

  lifecycle_rule {
    enabled = true

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
    expiration {
      days = 365
    }
  }

  versioning {
    enabled = true
  }

  policy = <<JSON
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${local.service_account_id}:root"
            },
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3:Put*",
                "s3:Delete*"
            ],
            "Resource": [
                "arn:aws:s3:::${local.lambda_bucket}/*"
            ]
        }
    ]
}
JSON

  tags = {
    service = local.service_name
  }
}

resource "aws_s3_bucket_public_access_block" "lambda_function" {
  count = local.on_common ? 1 : 0

  bucket = aws_s3_bucket.lambda_function[0].id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
