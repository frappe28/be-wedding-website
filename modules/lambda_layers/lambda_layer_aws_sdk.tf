resource "aws_lambda_layer_version" "aws_sdk" {
  filename                 = "${path.module}/layers/aws-sdk-2-1035-0.zip"
  layer_name               = "aws-sdk-2-1035-0"
  compatible_architectures = ["x86_64"]
  compatible_runtimes      = ["nodejs18.x"]
}
