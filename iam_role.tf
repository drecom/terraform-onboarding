#
# For lambda
#

resource "aws_iam_role" "lambda" {
  count = local.on_common ? 1 : 0

  name               = format("%s-%s", local.service_name, "lambda-exec")
  assume_role_policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
            "Service": [
                "lambda.amazonaws.com"
            ]
        }
    }
  ]
}
JSON

}

resource "aws_iam_role_policy" "lambda" {
  count = local.on_common ? 1 : 0

  name   = format("%s-%s", local.service_name, "lambda-add")
  role   = aws_iam_role.lambda[0].id
  policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cloudwatch:*",
        "lambda:*",
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": "iam:PassRole",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
JSON

}


#
# App runner
#
resource "aws_iam_role" "apprunner" {
  count = local.on_common ? 1 : 0

  name = format("%s-%s", local.service_name, "apprunner")

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "build.apprunner.amazonaws.com",
          "tasks.apprunner.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "apprunner" {
  count = local.on_common ? 1 : 0

  role       = aws_iam_role.apprunner[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}
