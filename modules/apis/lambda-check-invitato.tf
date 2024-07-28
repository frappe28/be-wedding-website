locals {
  lambda_name_controllo_invitato = "${var.env}-${var.project}-controllo-invitato"
}
resource "aws_lambda_function" "controllo_invitato" {
  role          = aws_iam_role.lambda_role_controllo_invitato.arn
  function_name = local.lambda_name_controllo_invitato
  s3_bucket     = aws_s3_bucket.lambdas.bucket
  s3_key        = "${local.lambda_name_controllo_invitato}.zip"
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

resource "aws_cloudwatch_log_group" "controllo_invitato" {
  name              = "/aws/lambda/${local.lambda_name_controllo_invitato}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "controllo_invitato" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.controllo_invitato.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api.id}/*/GET/controllo-invitato"
}

data "aws_iam_policy_document" "assume_role_controllo_invitato" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role_controllo_invitato" {
  name               = local.lambda_name_controllo_invitato
  assume_role_policy = data.aws_iam_policy_document.assume_role_controllo_invitato.json
}

resource "aws_iam_role_policy_attachment" "basic_controllo_invitato" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role_controllo_invitato.name
}

resource "aws_iam_policy" "controllo_invitati" {
  name   = local.lambda_name_controllo_invitato
  policy = data.aws_iam_policy_document.lambda_controllo_invitati.json
}

resource "aws_iam_role_policy_attachment" "att_controllo_invitato" {
  role       = aws_iam_role.lambda_role_controllo_invitato.name
  policy_arn = aws_iam_policy.controllo_invitati.arn
}

data "aws_iam_policy_document" "lambda_controllo_invitati" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:BatchGet*",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:Get*",
      "dynamodb:Query",
      "dynamodb:Scan",
    ]

    resources = [
      data.aws_dynamodb_table.invitati.arn
    ]
  }
}
