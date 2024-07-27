resource "aws_s3_bucket" "lambdas" {
  bucket = "${var.env}-${var.project}-lambdas"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambdas" {
  bucket = aws_s3_bucket.lambdas.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "lambdas" {
  bucket                  = aws_s3_bucket.lambdas.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

