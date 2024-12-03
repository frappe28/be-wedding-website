locals {
  topic_invia_notifica = "${var.env}-${var.project}-notifica-invitati"
}

resource "aws_sns_topic" "notifications" {
  name = local.topic_invia_notifica
}
