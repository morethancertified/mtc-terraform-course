locals {
  ecr_url   = aws_ecr_repository.this.repository_url
  ecr_token = data.aws_ecr_authorization_token.this
}

data "aws_ecr_authorization_token" "this" {}

resource "aws_ecr_repository" "this" {
  name         = var.ecr_repository_name
  force_delete = true
}


resource "terraform_data" "login" {
  provisioner "local-exec" {
    command = <<EOT
        docker login ${local.ecr_url} \
        --username ${local.ecr_token.user_name} \
        --password ${local.ecr_token.password}
        EOT
  }
}

resource "terraform_data" "build" {
  depends_on = [terraform_data.login]
  provisioner "local-exec" {
    command = <<EOT
        docker build -t ${local.ecr_url} ${path.module}/apps/${var.app_path}
        EOT
  }
}

