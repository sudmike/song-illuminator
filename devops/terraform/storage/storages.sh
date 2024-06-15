#!/usr/bin/env bash

stages=("dev" "prod") # stages to create

for stage in "${stages[@]}"; do
  export AWS_PROFILE=${stage}
  echo "Processing stage: $stage"

  # Initialize Terraform
  terraform init \
    -reconfigure \
    -backend-config="path=${stage}.tfstate"

  # Get account infos for Terraform variable
  account_id=$(aws sts get-caller-identity --query Account --output text)
  suffix=${account_id:(-6)} # last six characters of account id are suffix for globally unique storage bucket

  # Apply a Terraform plan to create storage buckets
  terraform apply \
    -var "stage=${stage}" \
    -var "storage_name=devops-terraform-state-${suffix}"

done
