# ERPNext on AWS with Terraform

Deploy ERPNext to AWS EKS with external RDS MariaDB using Terraform.

## Features

- VPC with configurable subnets (public, private, database)
- EKS cluster with managed node groups
- RDS MariaDB database
- S3 bucket for backups
- Helm-based ERPNext deployment

## Quick Start

1. Clone this repository
2. Configure your AWS credentials
3. Review and modify `terraform.tfvars`
4. Deploy: `terraform init && terraform apply`

## Variables

See `variables.tf` for all configurable options including subnet CIDR blocks.