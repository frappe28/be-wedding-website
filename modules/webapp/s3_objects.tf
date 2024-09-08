resource "aws_s3_object" "libretto" {
  bucket      = aws_s3_bucket.fe.bucket
  key         = "docs/libretto.pdf"
  source      = "${path.module}/assets/libretto.pdf"
  source_hash = filemd5("${path.module}/assets/libretto.pdf")
}

resource "aws_s3_object" "logo" {
  for_each     = fileset("${path.module}/assets/photos", "*.jpg")
  bucket       = aws_s3_bucket.fe.bucket
  key          = "photos/${each.value}"
  source       = "${path.module}/assets/photos/${each.key}"
  content_type = "image/png"
  source_hash  = filemd5("${path.module}/assets/photos/${each.key}")
}
