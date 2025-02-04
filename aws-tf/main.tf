# Root Main.tf

module "infra" {
  source   = "./modules/infra"
  vpc_cidr = "10.0.0.0/16"
  num_subnets = 2
}
