locals {
  lambda_invia_notifica = "${var.env}-${var.project}-invia-notifica"
}
resource "aws_lambda_function" "invia_notifica" {
  role          = aws_iam_role.lambda_role_invia_notifica.arn
  function_name = local.lambda_invia_notifica
  s3_bucket     = data.aws_s3_bucket.lambdas.bucket
  s3_key        = "${local.lambda_invia_notifica}.zip"
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

resource "aws_cloudwatch_log_group" "invia_notifica" {
  name              = "/aws/lambda/${local.lambda_invia_notifica}"
  retention_in_days = 30
}

data "aws_iam_policy_document" "assume_role_invia_notifica" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role_invia_notifica" {
  name               = local.lambda_invia_notifica
  assume_role_policy = data.aws_iam_policy_document.assume_role_invia_notifica.json
}

resource "aws_iam_role_policy_attachment" "basic_invia_notifica" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role_invia_notifica.name
}

resource "aws_iam_policy" "controllo_invitati" {
  name   = local.lambda_invia_notifica
  policy = data.aws_iam_policy_document.lambda_invia_notifica.json
}

resource "aws_iam_role_policy_attachment" "att_invia_notifica" {
  role       = aws_iam_role.lambda_role_invia_notifica.name
  policy_arn = aws_iam_policy.controllo_invitati.arn
}

data "aws_iam_policy_document" "lambda_invia_notifica" {
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

  statement {
    effect = "Allow"

    actions = [
      "sns:Publish"
    ]

    resources = ["*"]
  }
}
