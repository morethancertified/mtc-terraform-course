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

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.app_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = "${local.ecr_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.port
          hostPort      = var.port
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "${var.app_name}-service"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.app_security_group_id]
    assign_public_ip = var.is_public
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = var.app_name
    container_port   = var.port
  }
}

resource "aws_lb_target_group" "ecs_tg" {
  name        = "ecs-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

