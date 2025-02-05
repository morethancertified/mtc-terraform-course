resource "aws_ecr_repository" "this" {
  name         = var.ecr_repository_name
  force_delete = true
}