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
}
