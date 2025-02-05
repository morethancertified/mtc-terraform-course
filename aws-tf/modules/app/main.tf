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

resource "terraform_data" "push" {
  triggers_replace = [
    var.image_version
  ]
  depends_on = [terraform_data.login, terraform_data.build]
  provisioner "local-exec" {
    command = <<EOT
        docker image tag ${local.ecr_url} ${local.ecr_url}:${var.image_version}
        docker image tag ${local.ecr_url} ${local.ecr_url}:latest
        docker image push ${local.ecr_url}:${var.image_version}
        docker image push ${local.ecr_url}:latest
        EOT
  }
}