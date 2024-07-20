# resource "aws_acm_certificate_validation" "auth" {
#   certificate_arn = data.aws_acm_certificate.auth.arn
# }

# resource "aws_api_gateway_domain_name" "auth" {
#   regional_certificate_arn = aws_acm_certificate_validation.auth.certificate_arn
#   domain_name              = var.auth_api_custom_domain_name
#   security_policy          = "TLS_1_2"
#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }

#   tags = {
#     Name = var.auth_api_custom_domain_name
#   }
# }

resource "aws_api_gateway_rest_api" "api" {
  name = "${var.env}-${var.project}-apis"
  body = templatefile("${path.module}/swaggers/swagger.yml",
    {
      region = var.region
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

resource "aws_api_gateway_base_path_mapping" "auth" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_deployment.deployment.stage_name
  domain_name = aws_api_gateway_domain_name.auth.domain_name
}

resource "aws_api_gateway_method_settings" "auth_all" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_deployment.deployment.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
  }
}

resource "aws_cloudwatch_log_group" "auth_api" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.api.id}/${var.env}"
  retention_in_days = 30
}
