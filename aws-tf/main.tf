# Root Main.tf

data "aws_secretsmanager_secret" "openai_api_key" {
  name = "openaikey"
}

locals {
  apps = {
    ui = {
      ecr_repository_name = "ui"
      app_path            = "ui"
      image_version       = "1.0.1"
      app_name            = "ui"
      port                = 80
      is_public           = true
      path_pattern        = "/*"
      lb_priority         = 20
      healthcheck_path    = "/"
      secrets             = [{}]
      envars              = [{}]
    }
    api = {
      ecr_repository_name = "api"
      app_path            = "api"
      image_version       = "1.0.4"
      app_name            = "api"
      port                = 5000
      is_public           = true
      path_pattern        = "/api/*"
      lb_priority         = 10
      healthcheck_path    = "/api/healthcheck"
      secrets             = [{ name = "OPENAI_API_KEY", valueFrom = data.aws_secretsmanager_secret.openai_api_key.arn }]
      envars              = [{}]
    }
  }
}

module "infra" {
  source      = "./modules/infra"
  vpc_cidr    = "10.0.0.0/16"
  num_subnets = 3
  allowed_ips = ["0.0.0.0/0"]
}

resource "local_file" "dockerfile" {
  content  = templatefile("modules/app/apps/templates/ui.tftpl", { build_args = { "backend_url" = module.infra.alb_dns_name } })
  filename = "modules/app/apps/ui/Dockerfile"
}

module "app" {
  source                = "./modules/app"
  depends_on            = [local_file.dockerfile]
  for_each              = local.apps
  ecr_repository_name   = each.value.ecr_repository_name
  app_path              = each.value.app_path
  image_version         = each.value.image_version
  app_name              = each.value.app_name
  port                  = each.value.port
  is_public             = each.value.is_public
  path_pattern          = each.value.path_pattern
  envars                = each.value.envars
  secrets               = each.value.secrets
  healthcheck_path      = each.value.healthcheck_path
  lb_priority           = each.value.lb_priority
  execution_role_arn    = module.infra.execution_role_arn
  app_security_group_id = module.infra.app_security_group_id
  subnets               = module.infra.public_subnets
  cluster_arn           = module.infra.cluster_arn
  vpc_id                = module.infra.vpc_id
  alb_listener_arn      = module.infra.alb_listener_arn

}

output "alb_dns_name" {
  value = "http://${module.infra.alb_dns_name}"
}