locals {
  lambda_name_get_tavolo = "${var.env}-${var.project}-get-tavolo"
}
resource "aws_lambda_function" "get_tavolo" {
  role          = aws_iam_role.lambda_role_get_tavolo.arn
  function_name = local.lambda_name_get_tavolo
  s3_bucket     = aws_s3_bucket.lambdas.bucket
  s3_key        = "${local.lambda_name_get_tavolo}.zip"
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

resource "aws_cloudwatch_log_group" "get_tavolo" {
  name              = "/aws/lambda/${local.lambda_name_get_tavolo}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "get_tavolo" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_tavolo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api.id}/*/GET/get-tavolo"
}

data "aws_iam_policy_document" "assume_role_get_tavolo" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role_get_tavolo" {
  name               = local.lambda_name_get_tavolo
  assume_role_policy = data.aws_iam_policy_document.assume_role_get_tavolo.json
}

resource "aws_iam_role_policy_attachment" "basic_get_tavolo" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role_get_tavolo.name
}

resource "aws_iam_policy" "get_tavolo" {
  name   = local.lambda_name_get_tavolo
  policy = data.aws_iam_policy_document.lambda_get_tavolo.json
}

resource "aws_iam_role_policy_attachment" "att_get_tavolo" {
  role       = aws_iam_role.lambda_role_get_tavolo.name
  policy_arn = aws_iam_policy.get_tavolo.arn
}

data "aws_iam_policy_document" "lambda_get_tavolo" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:Get*",
      "dynamodb:Query",
    ]

    resources = [
      data.aws_dynamodb_table.invitati.arn
    ]
  }
}
