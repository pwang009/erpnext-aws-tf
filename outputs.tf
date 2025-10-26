output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_address
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.db_instance_port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.rds.db_instance_name
}

output "rds_username" {
  description = "RDS database username"
  value       = local.db_username
  sensitive   = true
}

output "s3_bucket_name" {
  description = "S3 bucket for backups"
  value       = aws_s3_bucket.erpnext_backup.bucket
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "load_balancer_url" {
  description = "ERPNext Load Balancer URL"
  value       = "http://${data.kubernetes_service.erpnext_nginx.status.0.load_balancer.0.ingress.0.hostname}"
}