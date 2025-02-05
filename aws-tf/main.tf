# Root Main.tf

module "infra" {
  source      = "./modules/infra"
  vpc_cidr    = "10.0.0.0/16"
  num_subnets = 2
  allowed_ips = ["0.0.0.0/0"]
}

module "app" {
  source                = "./modules/app"
  ecr_repository_name   = "ui"
  app_path              = "ui"
  image_version         = "1.0.1"
  app_name              = "ui"
  port                  = 80
  execution_role_arn    = module.infra.execution_role_arn
  app_security_group_id = module.infra.app_security_group_id
  subnets               = module.infra.public_subnets
  cluster_arn           = module.infra.cluster_arn
  is_public             = true
  vpc_id                = module.infra.vpc_id
}
