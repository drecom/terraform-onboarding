resource "aws_ecr_repository" "sample-app" {
  count = local.on_system ? 1 : 0

  name                 = "sample-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}