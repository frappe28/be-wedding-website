variable "project" {
  type        = string
  description = "Project name."
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "env" {
  type        = string
  description = "Environment"
}

variable "account_id" {
  type        = string
  description = "Account ID"
}

variable "dynamo_invitati_name" {
  type        = string
  description = "Nome della tabella dynamo degli invitati"
}
