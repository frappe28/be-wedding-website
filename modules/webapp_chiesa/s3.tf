resource "aws_s3_bucket" "fe_chiesa" {
  bucket = "${var.env}-${var.project}-chiesa-frontend"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "fe_chiesa" {
  bucket = aws_s3_bucket.fe_chiesa.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "webapp" {
  bucket = aws_s3_bucket.fe_chiesa.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "allow-access"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
        ]
        Resource = [
          aws_s3_bucket.fe_chiesa.arn,
          "${aws_s3_bucket.fe_chiesa.arn}/*",
        ]
      },
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "fe_chiesa" {
  bucket = aws_s3_bucket.fe_chiesa.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

}

