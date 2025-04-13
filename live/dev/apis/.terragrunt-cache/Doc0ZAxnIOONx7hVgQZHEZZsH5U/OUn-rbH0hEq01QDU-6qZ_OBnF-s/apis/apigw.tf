resource "aws_api_gateway_rest_api" "api" {
  name = "${var.env}-${var.project}-apis"
  body = templatefile("${path.module}/swaggers/swagger.yml",
    {
      region                    = var.region
      lambda_controllo_invitato = aws_lambda_function.controllo_invitato.function_name
      lambda_conferma_presenza  = aws_lambda_function.conferma_presenza.function_name
      lambda_get_invitato       = aws_lambda_function.get_invitato.function_name
      lambda_get_tavolo         = aws_lambda_function.get_tavolo.function_name
      account_id                = var.account_id
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.env

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_usage_plan" "default_usage_plan" {
  name = "${var.env}-${var.project}-apis"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_deployment.deployment.stage_name
  }

}

resource "aws_api_gateway_method_settings" "auth_all" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_deployment.deployment.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
  }
}

resource "aws_cloudwatch_log_group" "auth_api" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.api.id}/${var.env}"
  retention_in_days = 30
}

resource "aws_api_gateway_account" "default" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

data "aws_iam_policy_document" "cloudwatch_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudwatch" {
  name = "${var.env}-${var.project}-apis-gateway-cloudwatch"

  assume_role_policy = data.aws_iam_policy_document.cloudwatch_role.json
}

data "aws_iam_policy_document" "cloudwatch_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "${var.env}-${var.project}-apis"
  role = aws_iam_role.cloudwatch.id

  policy = data.aws_iam_policy_document.cloudwatch_policy.json
}
