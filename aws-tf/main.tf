# Root Main.tf

# module "infra" {
#   source      = "./modules/infra"
#   vpc_cidr    = "10.0.0.0/16"
#   num_subnets = 2
#   allowed_ips = ["0.0.0.0/0"]
# }

data "terraform_remote_state" "infra" {
  backend = "remote"

  config = {
    organization = "mtc-tf-2024"
    workspaces = {
      name = "ecs-infra"
    }
  }
}

locals {
  datasource = data.terraform_remote_state.infra.outputs
}

output "datasource" {
  value = data.terraform_remote_state.infra.outputs
}

module "app" {
  source                = "./modules/app"
  ecr_repository_name   = "ui"
  app_path              = "ui"
  image_version         = "1.0.1"
  app_name              = "ui"
  port                  = 80
  is_public             = true
  path_pattern          = "/*"
  # execution_role_arn    = module.infra.execution_role_arn
  # app_security_group_id = module.infra.app_security_group_id
  # subnets               = module.infra.public_subnets
  # cluster_arn           = module.infra.cluster_arn
  # vpc_id                = module.infra.vpc_id
  # alb_listener_arn      = module.infra.alb_listener_arn
  execution_role_arn    = local.datasource.execution_role_arn
  app_security_group_id = local.datasource.app_security_group_id
  subnets               = local.datasource.public_subnets
  cluster_arn           = local.datasource.cluster_arn
  vpc_id                = local.datasource.vpc_id
  alb_listener_arn      = local.datasource.alb_listener_arn
}



