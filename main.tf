terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

  backend "s3" {
    # Configure backend in environments/production/backend.tf
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "vpc" {
  source = "./modules/vpc"

  project_name     = var.project_name
  vpc_cidr         = var.vpc_cidr
  environment      = var.environment
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets
  availability_zones = var.availability_zones
}

module "eks" {
  source = "./modules/eks"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  eks_instance_types  = var.eks_instance_types
  eks_desired_size    = var.eks_desired_size
  eks_min_size        = var.eks_min_size
  eks_max_size        = var.eks_max_size

  depends_on = [module.vpc]
}

module "rds" {
  source = "./modules/rds"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  database_subnet_ids   = module.vpc.database_subnet_ids
  eks_security_group_id = module.eks.cluster_security_group_id
  rds_instance_class    = var.rds_instance_class
  rds_allocated_storage = var.rds_allocated_storage

  depends_on = [module.vpc, module.eks]
}

# S3 Bucket for backups
resource "aws_s3_bucket" "erpnext_backup" {
  bucket_prefix = "${var.project_name}-backup-"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "erpnext_backup" {
  bucket = aws_s3_bucket.erpnext_backup.id
  versioning_configuration {
    status = "Enabled"
  }
}terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

  backend "s3" {
    # Configure backend in environments/production/backend.tf
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "vpc" {
  source = "./modules/vpc"

  project_name     = var.project_name
  vpc_cidr         = var.vpc_cidr
  environment      = var.environment
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets
  availability_zones = var.availability_zones
}

module "eks" {
  source = "./modules/eks"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  eks_instance_types  = var.eks_instance_types
  eks_desired_size    = var.eks_desired_size
  eks_min_size        = var.eks_min_size
  eks_max_size        = var.eks_max_size

  depends_on = [module.vpc]
}

module "rds" {
  source = "./modules/rds"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  database_subnet_ids   = module.vpc.database_subnet_ids
  eks_security_group_id = module.eks.cluster_security_group_id
  rds_instance_class    = var.rds_instance_class
  rds_allocated_storage = var.rds_allocated_storage

  depends_on = [module.vpc, module.eks]
}

# S3 Bucket for backups
resource "aws_s3_bucket" "erpnext_backup" {
  bucket_prefix = "${var.project_name}-backup-"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "erpnext_backup" {
  bucket = aws_s3_bucket.erpnext_backup.id
  versioning_configuration {
    status = "Enabled"
  }
}