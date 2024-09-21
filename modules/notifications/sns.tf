locals {
  topic_invia_notifica = "${var.env}-${var.project}-notifica-invitati"
}

resource "aws_sns_topic" "notifications" {
  name = local.topic_invia_notifica
}

# da rimuovere quando non saremo più in sandbox
resource "aws_sns_topic_subscription" "tel_fradeps" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "sms"
  endpoint  = "+393923923453"
}
resource "aws_sns_topic_subscription" "tel_frasanz" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "sms"
  endpoint  = "+393426734350"
}
