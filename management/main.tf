terraform {
  cloud {

    organization = "mtc-tf-2024"

    workspaces {
      name = "state-buckets"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  buckets = {
    "dev"  = "mtc-app-state-21125"
    "prod" = "mtc-app-state-21126"
  }
}

# import {
#   for_each = local.buckets
#   to = aws_s3_bucket.this[each.key]
#   id = each.value
# }

resource "aws_s3_bucket" "this" {
    for_each = local.buckets
    force_destroy = true
}