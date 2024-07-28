locals {
  lambda_name_conferma_presenza = "${var.env}-${var.project}-conferma-presenza"
}
resource "aws_lambda_function" "conferma_presenza" {
  role          = aws_iam_role.lambda_role_conferma_presenza.arn
  function_name = local.lambda_name_conferma_presenza
  s3_bucket     = aws_s3_bucket.lambdas.bucket
  s3_key        = "${local.lambda_name_conferma_presenza}.zip"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 30

  layers = [
    var.aws_sdk_lambda_layer_version_arn
  ]

  environment {
    variables = {
      REGION                       = var.region
      DYNAMODB_INVITATI_TABLE_NAME = data.aws_dynamodb_table.invitati.name
    }
  }
}

resource "aws_cloudwatch_log_group" "conferma_presenza" {
  name              = "/aws/lambda/${local.lambda_name_conferma_presenza}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "conferma_presenza" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.conferma_presenza.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api.id}/*/POST/conferma-presenza"
}

data "aws_iam_policy_document" "assume_role_conferma_presenza" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role_conferma_presenza" {
  name               = local.lambda_name_conferma_presenza
  assume_role_policy = data.aws_iam_policy_document.assume_role_conferma_presenza.json
}

resource "aws_iam_role_policy_attachment" "basic_conferma_presenza" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role_conferma_presenza.name
}

resource "aws_iam_policy" "conferma_presenza" {
  name   = local.lambda_name_conferma_presenza
  policy = data.aws_iam_policy_document.lambda_conferma_presenza.json
}

resource "aws_iam_role_policy_attachment" "att_conferma_presenza" {
  role       = aws_iam_role.lambda_role_conferma_presenza.name
  policy_arn = aws_iam_policy.conferma_presenza.arn
}

data "aws_iam_policy_document" "lambda_conferma_presenza" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:BatchGet*",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:Put*",
    ]

    resources = [
      data.aws_dynamodb_table.invitati.arn
    ]
  }
}
