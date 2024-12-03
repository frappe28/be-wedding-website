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

dependency "lambda_layers" {
  config_path = "../lambda_layers"

  mock_outputs = {
    aws_sdk_lambda_layer_version_arn = "aws_sdk_lambda_layer_version_arn"
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
  aws_sdk_lambda_layer_version_arn   = dependency.lambda_layers.outputs.aws_sdk_lambda_layer_version_arn

  events = [
    {
      schedule_expression = "cron(0 8 30 4 ? 2025)",  # 30 aprile 2025 alle 9:00 (check UTC)
      name                = "reminder_2_settimane", 
      description         = "Promemoria per il matrimonio", 
      message             = "Pronti? Manca solo 1 settimana al matrimonio di Franci e Franci! Hai confermato la tua presenza, vero? https://d25ynqiopfm3p.cloudfront.net"
    },
    {
      schedule_expression = "cron(0 8 14 5 ? 2025)", # 14 maggio 2025 alle 9:00 (check UTC)
      name                = "giorno_del_matrimonio", 
      description         = "Giorno del matrimonio", 
      message             = "Oggi è il grande giorno! Benvenuti al matrimonio di Franci e Franci!"
    },
    {
      schedule_expression = "cron(30 9 14 5 ? 2025)", # 14 maggio 2025 alle 10:30 (check UTC)
      name                = "link_libretto_messa", 
      description         = "Link al libretto della messa", 
      message             = "Ecco il link al libretto della messa: https://d25ynqiopfm3p.cloudfront.net/docs/libretto.pdf"
    },
    {
      schedule_expression = "cron(0 9 14 5 ? 2025)",  # 14 maggio 2025 alle 10:00 (check UTC)
      name                = "link_indicazioni_chiesa", 
      description         = "Link per le indicazioni in chiesa", 
      message             = "Ecco il link con le indicazioni per arrivare in chiesa: https://maps.app.goo.gl/QFdxucjyQtXxkV387"
    },
    {
      schedule_expression = "cron(0 11 14 5 ? 2025)",  # 14 maggio 2025 alle 12:30 (check UTC)
      name                = "link_indicazioni_sala", 
      description         = "Link per le indicazioni in sala", 
      message             = "Ecco il link con le indicazioni per arrivare alla sala: https://maps.app.goo.gl/VrxD3yGckzizqnEbA"
    }
  ]
}