locals {
  lambda_name = "${var.env}-${var.project}-controllo-invitato"
}
resource "aws_lambda_function" "controllo_invitato" {
  filename         = "${path.module}/lambdas/controllo-invitato/build.zip"
  role             = aws_iam_role.lambda_role.arn
  function_name    = local.lambda_name
  source_code_hash = data.archive_file.controllo_invitato.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  timeout          = 10

  environment {
    variables = {
      REGION                       = var.region
      DYNAMODB_INVITATI_TABLE_NAME = data.aws_dynamodb_table.invitati.name
    }
  }
}

data "archive_file" "controllo_invitato" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/controllo-invitato/src/"
  output_path = "${path.module}/lambdas/controllo-invitato/build.zip"

  depends_on = [
    null_resource.yarn_install_controllo_invitato
  ]
}

resource "null_resource" "yarn_install_controllo_invitato" {
  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/lambdas/controllo-invitato"
    command     = "yarn --frozen-lockfile --mutex network"
  }

  # provisioner "local-exec" {
  #   working_dir = "${path.module}/lambdas/controllo-invitato"
  #   command     = "yarn build"
  # }
}

resource "aws_cloudwatch_log_group" "controllo_invitato" {
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "controllo_invitato" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.controllo_invitato.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api.id}/*/GET/controllo-invitato"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = local.lambda_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_policy" "controllo_invitati" {
  name   = local.lambda_name
  policy = data.aws_iam_policy_document.lambda_controllo_invitati.json
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.lambda_role.name
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
