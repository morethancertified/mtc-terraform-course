# terraform {
#   backend "local" {
#     path = "../state/terraform.tfstate"
#   }
# }

terraform { 
  cloud { 
    
    organization = "mtc-tf-2024" 

    workspaces { 
      name = "dev" 
    } 
  } 
}
