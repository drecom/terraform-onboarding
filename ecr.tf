resource "aws_ecr_repository" "sample-app" {
  count = local.on_system ? 1 : 0

  name                 = format("%s-%s", local.service_name, local.apprunner_service_name)
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}