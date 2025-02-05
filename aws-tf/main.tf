# Root Main.tf

module "infra" {
  source      = "./modules/infra"
  vpc_cidr    = "10.0.0.0/16"
  num_subnets = 2
  allowed_ips = ["0.0.0.0/0"]
}

module "app" {
  source              = "./modules/app"
  ecr_repository_name = "ui"
  app_path            = "ui"
  image_version       = "1.0.1"
  app_name            = "ui"
  port                = 80
  execution_role_arn  = module.infra.execution_role_arn
}
