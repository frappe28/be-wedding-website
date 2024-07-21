resource "aws_dynamodb_table" "invitati" {
  name         = "${var.env}-${var.project}-invitati"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
