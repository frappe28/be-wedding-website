locals {
  lambda_name_get_invitato = "${var.env}-${var.project}-get-invitato"
}
resource "aws_lambda_function" "get_invitato" {
  role          = aws_iam_role.lambda_role_get_invitato.arn
  function_name = local.lambda_name_get_invitato
  s3_bucket     = aws_s3_bucket.lambdas.bucket
  s3_key        = "${local.lambda_name_get_invitato}.zip"
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

resource "aws_cloudwatch_log_group" "get_invitato" {
  name              = "/aws/lambda/${local.lambda_name_get_invitato}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "get_invitato" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_invitato.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api.id}/*/GET/get-invitato"
}

data "aws_iam_policy_document" "assume_role_get_invitato" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role_get_invitato" {
  name               = local.lambda_name_get_invitato
  assume_role_policy = data.aws_iam_policy_document.assume_role_get_invitato.json
}

resource "aws_iam_role_policy_attachment" "basic_get_invitato" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role_get_invitato.name
}

resource "aws_iam_policy" "get_invitato" {
  name   = local.lambda_name_get_invitato
  policy = data.aws_iam_policy_document.lambda_get_invitato.json
}

resource "aws_iam_role_policy_attachment" "att_get_invitato" {
  role       = aws_iam_role.lambda_role_get_invitato.name
  policy_arn = aws_iam_policy.get_invitato.arn
}

data "aws_iam_policy_document" "lambda_get_invitato" {
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
