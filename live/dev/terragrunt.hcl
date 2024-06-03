locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  stage_vars  = read_terragrunt_config("${path_relative_from_include()}/stage.hcl")

  global = local.global_vars.locals
  stage  = local.stage_vars.locals
}

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${local.stage.env}-${local.global.project}-terragruntstate"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.global.region
    dynamodb_table = "${local.stage.env}-${local.global.project}-terragruntstate"
    s3_bucket_tags = {
      Project              = "${local.global.tags.project}"
      "Creation Date"       = "${formatdate("YYYY-MM-DD", timestamp())}"
      Environment           = "${local.stage.env}"
    }
    dynamodb_table_tags = {
      Project              = "${local.global.tags.project}"
      "Creation Date"       = "${formatdate("YYYY-MM-DD", timestamp())}"
      Environment           = "${local.stage.env}"
    }
  }
}

terraform {
  source = "${path_relative_from_include()}/../../modules//${split("-", path_relative_to_include())[0]}"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
  provider "aws" {
    region = "${local.global.region}"
    default_tags {
      tags = {
        Project              = "${local.global.tags.project}"
        "Creation Date"       = "${formatdate("YYYY-MM-DD", timestamp())}"
        Environment           = "${local.stage.env}"
      }
    }
    ignore_tags {
      keys = [ "Creation Date" ]
    }
  }
  provider "aws" {
    alias = "virginia"
    region = "us-east-1"
    default_tags {
      tags = {
        Project              = "${local.global.tags.project}"
        "Creation Date"       = "${formatdate("YYYY-MM-DD", timestamp())}"
        Environment           = "${local.stage.env}"
      }
    }
    ignore_tags {
      keys = [ "Creation Date" ]
    }
  }
  EOF
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
  terraform {
    backend "s3" {}
  }
  EOF
}