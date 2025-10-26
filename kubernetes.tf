locals {
  cluster_name        = "${var.project_name}-cluster"
  db_name            = "${var.project_name}_db"
  db_username        = "${var.project_name}dbadm"
}

# RDS MariaDB
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "${var.project_name}-mariadb"

  engine               = "mariadb"
  engine_version       = "10.11"
  family               = "mariadb10.11"
  major_engine_version = "10.11"

  instance_class      = var.rds_instance_class
  allocated_storage   = var.rds_allocated_storage
  max_allocated_storage = 100
  storage_encrypted   = true

  db_name  = local.db_name
  username = local.db_username
  port     = 3306

  multi_az               = false
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  backup_retention_period = 7
  skip_final_snapshot     = false
  final_snapshot_identifier_prefix = "${var.project_name}-final"

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.iam_role_arn

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    },
    {
      name  = "collation_server"
      value = "utf8mb4_unicode_ci"
    }
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Kubernetes Provider
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token

  experiments {
    manifest_resource = true
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Kubernetes namespace
resource "kubernetes_namespace" "erpnext" {
  metadata {
    name = var.project_name
    labels = {
      name = var.project_name
    }
  }
}

# Storage Class
resource "kubernetes_manifest" "storage_class" {
  manifest = {
    apiVersion = "storage.k8s.io/v1"
    kind       = "StorageClass"
    metadata = {
      name = "ebs-sc"
    }
    provisioner = "ebs.csi.aws.com"
    volumeBindingMode = "WaitForFirstConsumer"
    parameters = {
      type = "gp3"
      encrypted = "true"
    }
  }
}

# Database password secret
resource "kubernetes_secret" "erpnext_db_secret" {
  metadata {
    name      = "${var.project_name}-db-secret"
    namespace = kubernetes_namespace.erpnext.metadata[0].name
  }

  data = {
    password = module.rds.db_instance_password
  }

  depends_on = [module.rds]
}

# Helm release for ERPNext
resource "helm_release" "erpnext" {
  name       = var.project_name
  repository = "https://frappe.github.io/helm"
  chart      = "erpnext"
  version    = "2.0.0"
  namespace  = kubernetes_namespace.erpnext.metadata[0].name

  values = [
    templatefile("${path.module}/kubernetes/erpnext-helm-values.yml", {
      rds_endpoint      = module.rds.db_instance_address
      database_name     = local.db_name
      database_username = local.db_username
      database_password = module.rds.db_instance_password
      s3_bucket_name    = aws_s3_bucket.erpnext_backup.bucket
      aws_region        = var.aws_region
      project_name      = var.project_name
    })
  ]

  wait    = true
  timeout = 1200

  depends_on = [
    module.eks,
    module.rds,
    kubernetes_secret.erpnext_db_secret,
    kubernetes_manifest.storage_class
  ]
}

# Get Load Balancer URL
data "kubernetes_service" "erpnext_nginx" {
  metadata {
    name      = "${var.project_name}-nginx"
    namespace = kubernetes_namespace.erpnext.metadata[0].name
  }

  depends_on = [helm_release.erpnext]
}