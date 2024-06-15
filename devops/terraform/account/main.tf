terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
  backend "local" {}
}

# AWS account
resource "aws_organizations_account" "account" {
  name      = var.stage
  email     = var.aws-account-email
  role_name = "OrganizationAccountAccessRole"
  tags      = { stage = var.stage }
}
