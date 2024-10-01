# Creazione dinamica delle regole CloudWatch Event Rule
resource "aws_cloudwatch_event_rule" "lambda_schedule_rule" {
  for_each            = { for event in var.events : event.name => event }
  name                = each.value.name
  description         = each.value.description
  schedule_expression = each.value.schedule_expression
}

# Creazione dinamica dei target per invocare la Lambda
resource "aws_cloudwatch_event_target" "invoke_lambda_target" {
  for_each = { for event in var.events : event.name => event }

  rule      = aws_cloudwatch_event_rule.lambda_schedule_rule[each.value.name].name
  target_id = "${each.value.name}_lambda_target"
  arn       = aws_lambda_function.invia_notifica.arn

  input_transformer {
    input_template = jsonencode({
      "messaggio" : each.value.message
    })
  }
}

# Creazione dinamica dei permessi per invocare la Lambda dalla regola CloudWatch
resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_lambda" {
  for_each = aws_cloudwatch_event_rule.lambda_schedule_rule

  statement_id  = "${each.key}_AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.invia_notifica.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule_rule[each.key].arn
}
