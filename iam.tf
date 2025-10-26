# RDS Monitoring Role
resource "aws_iam_role" "rds_monitoring" {
  name_prefix = "${var.project_name}-rds-monitoring-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM Policy for S3 access
resource "aws_iam_policy" "erpnext_s3" {
  name_prefix = "${var.project_name}-s3-policy-"
  description = "Policy for ERPNext to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.erpnext_backup.arn,
          "${aws_s3_bucket.erpnext_backup.arn}/*"
        ]
      }
    ]
  })
}

# Attach S3 policy to EKS node group
resource "aws_iam_role_policy_attachment" "erpnext_s3" {
  policy_arn = aws_iam_policy.erpnext_s3.arn
  role       = module.eks.eks_managed_node_groups["nodes"].iam_role_name
}