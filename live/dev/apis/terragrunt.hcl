include "root" {
  path = find_in_parent_folders()
}

locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  stage_vars  = read_terragrunt_config(find_in_parent_folders("stage.hcl"))

  global = local.global_vars.locals
  stage  = local.stage_vars.locals
}

dependency "dynamodb" {
  config_path = "../dynamodb"

  mock_outputs = {
    dynamodb_table_sso   = "dynamo_invitati_name"
  }

  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan"
  ]

  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  project     = local.global.project
  region      = local.global.region
  env         = local.stage.env
  account_id  = get_aws_account_id()

  dynamo_invitati_name = dependency.dynamodb.outputs.dynamo_invitati_name
}