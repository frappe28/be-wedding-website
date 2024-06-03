locals {
  region              = "eu-west-1"
  project             = "francis-wedding"
  owner               = "francis"
  iam_role_arn_prefix = "arn:aws:iam::${get_aws_account_id()}:role/"

  tags = {
    project            = "Francis-Wedding"
  }
}
