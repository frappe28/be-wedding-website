resource "aws_cloudwatch_event_rule" "lambda_schedule_rule" {
  name        = "my_scheduled_event"
  description = "Esegue la Lambda a un orario specifico"

  # Espressione cron (Esempio: ogni giorno alle 8:00 AM UTC)
  # Formato cron: (minuto ora giorno-mese mese giorno-settimana anno)
  schedule_expression = "cron(46 11 21 9 ? 2024)"
}

# Collegamento tra la CloudWatch Rule e la Lambda
resource "aws_cloudwatch_event_target" "invoke_lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule_rule.name
  target_id = "lambda_target"
  arn       = aws_lambda_function.invia_notifica.arn

  input_transformer {
    input_template = jsonencode({
      "messaggio" : "benvenuto al matrimonio di franci e franci"
    })
  }
}

# Permessi per la Lambda di essere invocata dalla CloudWatch Rule
resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.invia_notifica.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule_rule.arn
}
