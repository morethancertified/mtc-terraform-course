resource "local_file" "repos" {
  content = jsonencode(local.repos)
  filename = "${path.module}/repos.json"
}

module "repos" {
  source           = "./modules/dev-repos"
  for_each         = var.environments
  repo_max         = 9
  env              = each.key
  # repos            = jsondecode(file("repos.json"))
  repos = { for v in csvdecode(file("repos.csv")) : v["environment"] => {for x, y  in v : x => lower(y) }}
  run_provisioners = false
}

module "deploy-key" {
  for_each  = var.deploy_key ? toset(flatten([for k, v in module.repos : keys(v.clone-urls) if k == "dev"])) : []
  source    = "./modules/deploy-key"
  repo_name = each.key
}

module "info-page" {
  source           = "./modules/info-page"
  repos            = { for k, v in module.repos["prod"].clone-urls : k => v }
  run_provisioners = false
}

output "repo-list" {
  value = flatten([for k, v in module.repos : keys(v.clone-urls) if k == "dev"])
}