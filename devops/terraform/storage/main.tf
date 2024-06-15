terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
  backend "local" {}
}

locals {
  tags = { stage = var.stage, service = "common" }
}

# Terraform state storage bucket
resource "aws_s3_bucket" "state" {
  bucket = var.storage_name
  tags   = local.tags
}

# Terraform state storage bucket lock
resource "aws_dynamodb_table" "lock" {
  name         = "devops-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  tags         = local.tags

  attribute {
    name = "LockID"
    type = "S"
  }
}
