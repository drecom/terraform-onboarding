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
                "lambda.amazonaws.com",
                "autoscaling.amazonaws.com"
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
          "arn:aws:kms:${local.region}:${local.service_account_id}:alias/aws/ssm"
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

resource "aws_iam_role_policy_attachment" "lambda_read_only" {
  count = local.on_common ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

#
# For EC2 profile
#

resource "aws_iam_instance_profile" "instance_profile" {
  count = local.on_common ? 1 : 0

  name = "instance_profile"
  role = aws_iam_role.instance_profile[0].name
}

resource "aws_iam_role" "instance_profile" {
  count = local.on_common ? 1 : 0

  name               = "instance_profile"
  assume_role_policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
JSON

}

resource "aws_iam_role_policy" "instance_profile" {
  count = local.on_common ? 1 : 0

  name   = "instance_profile"
  role   = aws_iam_role.instance_profile[0].id
  policy = <<JSON
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Action": [
                "acm:*",
                "directconnect:*",
                "marketplacecommerceanalytics:*",
                "route53:*",
                "route53domains:*",
                "support:*",
                "iam:Add*",
                "iam:Attach*",
                "iam:Change*",
                "iam:Create*",
                "iam:Deactivate*",
                "iam:Delete*",
                "iam:Detach*",
                "iam:Enable*",
                "iam:Generate*",
                "iam:Put*",
                "iam:Remove*",
                "iam:Reset*",
                "iam:Resync*",
                "iam:Set*",
                "iam:Update*",
                "iam:Upload*",
                "ec2:AcceptVpc*",
                "ec2:CreateVpc*",
                "ec2:CreateSubnet*",
                "ec2:CreateRoute*",
                "ec2:DeleteVpc*",
                "ec2:DeleteSubnet*",
                "ec2:DeleteRoute*",
                "ec2:Disassociate*",
                "ec2:ModifyVpc*",
                "ec2:ModifySubnet*",
                "ec2:RejectVpc*",
                "ec2:ReplaceRoute*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
JSON

}

