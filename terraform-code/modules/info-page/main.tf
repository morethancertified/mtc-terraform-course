data "terraform_remote_state" "infra" {
  backend = "remote"

  config = {
    organization = "mtc-tf-2024"
    workspaces = {
      name = "dev-repos"
    }
  }
}

locals {
  repos = { for k, v in data.terraform_remote_state.infra.outputs.clone_urls["prod"].clone-urls : k => v }
}

resource "github_repository" "this" {
  name        = "mtc_info_page"
  description = "Repository Information for MTC"
  visibility  = "public"
  auto_init   = true
  pages {
    source {
      branch = "main"
      path   = "/"
    }
  }
  provisioner "local-exec" {
    command = var.run_provisioners ? "gh repo view ${self.name} --web" : "echo 'Skip repo view'"
  }
}

data "github_user" "current" {
  username = ""
}

resource "time_static" "this" {}

resource "github_repository_file" "this" {
  repository          = github_repository.this.name
  branch              = "main"
  file                = "index.md"
  overwrite_on_create = true
  content = templatefile("${path.module}/templates/index.tftpl", {
    avatar = data.github_user.current.avatar_url,
    name   = data.github_user.current.name,
    date   = time_static.this.year,
    repos  = local.repos
  })
}

check "health_check" {
  data "http" "info_page" {
    url = github_repository.this.pages[0].html_url
    retry {
      attempts = 5
    }
  }
  assert {
    condition = data.http.info_page.status_code == 200
    error_message = "${data.http.info_page.url} is unhealthy"
  }
}