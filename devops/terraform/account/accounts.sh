#!/usr/bin/env bash

stages=("dev" "prod") # stages to create
suffix="" # optional email suffix in case an account with the email already exists

# Get organization infos for Terraform variable
aws_email=$(aws organizations describe-organization | jq -r '.Organization.MasterAccountEmail')

for stage in "${stages[@]}"; do
  export AWS_PROFILE=default
  echo "Processing stage: $stage"

  # Initialize Terraform
  terraform init \
    -reconfigure \
    -backend-config="path=${stage}.tfstate"

  # Generate unique email based on master email
  aws_stage_email="${aws_email%@*}+${stage}${suffix}@${aws_email#*@}" # email like example+dev@example.com, with suffix as "-foo" like example+dev-foo@example.com

  # Apply a Terraform plan to create AWS account
  terraform apply \
    -var "aws-account-email=${aws_stage_email}" \
    -var "stage=${stage}"

done
