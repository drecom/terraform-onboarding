#
# IAM role
#
resource "aws_iam_role" "apprunner" {
    count = local.on_service ? 1 : 0
    
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
    count = local.on_service ? 1 : 0

    role       = aws_iam_role.apprunner[0].name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

#
# App runner
#
resource "aws_apprunner_service" "sample-app" {
    count = local.on_service ? 1 : 0
  
    service_name = "sample-app"

    source_configuration {
      authentication_configuration {
        access_role_arn = aws_iam_role.apprunner[0].arn
      }
      image_repository {
        image_configuration {
          port = "8080"
        }
        image_identifier      = "${data.terraform_remote_state.system.outputs.ecr_url}:latest"
        image_repository_type = "ECR"
      }
    }

    tags = {
      Name = "sample-apprunner-service"
    }

    depends_on = [
    aws_iam_role.apprunner,
  ]
}

resource "aws_cloudwatch_log_group" "sample-app" {
  count = local.on_service ? 1 : 0

  name              = format("%s%s", "/aws/apprunner/", aws_apprunner_service.sample-app[0].service_name)
  retention_in_days = 7
}