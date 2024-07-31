locals {
  repos = {
    infra = {
      lang     = "terraform",
      filename = "main.tf",
      pages    = true
    },
    backend = {
      lang     = "python",
      filename = "main.py",
      pages    = false
    }
  }
  environments = toset(["dev", "prod"])
}


module "repos" {
  source   = "./modules/dev-repos"
  for_each = local.environments
  repo_max = 9
  env      = each.key
  repos = local.repos
}

output "repo-info" {
  value = { for k,v in module.repos : k => v.clone-urls }
}