data "aws_dynamodb_table" "invitati" {
  name = var.dynamo_invitati_name
}

data "aws_s3_bucket" "lambdas" {
  bucket = "${var.env}-${var.project}-lambdas"
}