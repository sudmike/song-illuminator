## Base setup

Follow these sections to set up structure for the project.

### Prerequisites

* [Install Terraform](https://developer.hashicorp.com/terraform/install)
* [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

### AWS organization

How to set up an AWS organization:

1. [Create an organization in AWS](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_org_create.html)
2. Create an administrative account user with the permission "AdministratorAccess"
3. Set up the CLI with the administrative user access key  
`aws configure`

### AWS accounts

How to set up stage AWS accounts in the organization:

1. Execute `accounts.sh`
2. Create an administrative account user with the permission "AdministratorAccess" per stage
3. Set up the CLI with the administrative user access key per stage
   `aws configure --profile dev`  
   `aws configure --profile prod`

### Terraform state storage

How to set up the Terraform state storage inside the stage AWS accounts:

1. Execute `storages.sh`
