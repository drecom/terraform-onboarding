#
# App runner
#
resource "aws_apprunner_service" "sample-app" {
    count = local.on_service ? 1 : 0
  
    service_name = "sample-app"

    source_configuration {
      authentication_configuration {
        access_role_arn = data.terraform_remote_state.common.outputs.aws_iam_role_apprunner_arn
      }
      image_repository {
        image_configuration {
          port = "3000"
        }
        image_identifier      = "${data.terraform_remote_state.system.outputs.ecr_url}:${local.ecr_repo_tag}"
        image_repository_type = "ECR"
      }
    }

    tags = {
      Name = "sample-apprunner-service"
    }
}
