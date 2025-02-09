module "repos" {
  source           = "./dev-repos"
  for_each         = var.environments
  repo_max         = 9
  env              = each.key
  repos = { for v in csvdecode(file("repos.csv")) : v["environment"] => {for x, y  in v : x => lower(y) }}
  run_provisioners = false
}

module "deploy-key" {
  for_each  = var.deploy_key ? toset(flatten([for k, v in module.repos : keys(v.clone-urls) if k == "dev"])) : []
  source    = "./deploy-key"
  repo_name = each.key
}