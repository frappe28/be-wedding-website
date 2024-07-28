# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
  provider "aws" {
    region = "eu-west-1"
    default_tags {
      tags = {
        Project              = "Francis-Wedding"
        "Creation Date"       = "2024-07-28"
        Environment           = "dev"
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
        Project              = "Francis-Wedding"
        "Creation Date"       = "2024-07-28"
        Environment           = "dev"
      }
    }
    ignore_tags {
      keys = [ "Creation Date" ]
    }
  }
