locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  global             = local.global_vars.locals

  env                                    = "prod"
  project                                = local.global.project
  resource_name_prefix_template          = "${local.project}-${local.env}"
}