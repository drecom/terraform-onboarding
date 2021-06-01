#
# VPC Flow Log
#
resource "aws_iam_role" "vpc-flow-log" {
  count = local.on_common ? 1 : 0

  name               = "flowlogsRole"
  assume_role_policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
JSON
}

resource "aws_iam_role_policy" "vpc-flow-log" {
  count = local.on_common ? 1 : 0

  name   = "vpc-flow-log"
  role   = aws_iam_role.vpc-flow-log[0].id
  policy = <<JSON
{
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
JSON
}
