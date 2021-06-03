#
# For lambda
#

resource "aws_iam_role" "lambda" {
  count = local.on_common ? 1 : 0

  name               = "lambda"
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

  name   = "lambda_additional"
  role   = aws_iam_role.lambda[0].id
  policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "acm:*",
        "cloudwatch:*",
        "lambda:*",
        "route53:*",
        "route53domains:*",
        "cloudfront:*",
        "autoscaling:*",
        "s3:*",
        "ec2:*",
        "elasticloadbalancing:*",
        "rds:Copy*",
        "rds:Download*",
        "rds:DeleteDB*Snapshot",
        "ecr:*",
        "ecs:*",
        "codebuild:*",
        "codepipeline:*",
        "sns:*",
        "servicequotas:*",
        "logs:*",
        "waf:*",
        "waf-regional:*",
        "health:*",
        "pricing:*",
        "support:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter*",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Resource": [
          "arn:aws:kms:${var.region}:${var.service_account_id}:alias/aws/ssm"
      ]
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
    
    name = "app-runner"

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
