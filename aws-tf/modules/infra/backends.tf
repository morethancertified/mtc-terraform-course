terraform { 
  cloud { 
    
    organization = "mtc-tf-2024"

    workspaces {
        name = "ecs-infra"
    } 

  } 
}
