terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    stdlib = {
      source = "mschuchard/stdlib"
      version = "1.6.0"
    }
  }
}

#Configure the GitHub Provider
provider "github" {
  owner = "morethancertified"
}