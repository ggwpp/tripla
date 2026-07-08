terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.25"
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    general = {
      capacity_type = "SPOT"

      min_size     = 1
      desired_size = 1
      max_size     = 3
    }
  }

  tags = {
    Environment = var.environment
  }
}

#
# S3: Not sure if we need S3 creation. I remain s3 part just incase we need it.
# Technically it is acceptable to use public-acl but not recommened for security and cost reasons
# Security: accidentlly upload sensitive data to this bucket
# Cost: Outbound data transfer without caching
#
resource "aws_s3_bucket" "static_assets" {
  count = var.create_s3 ? 1 : 0
  bucket = var.s3_bucket_name

  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "static_assets" {
  count = var.create_s3 ? 1 : 0

  bucket = aws_s3_bucket.static_assets[0].id

  block_public_acls       = false
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "static_assets" {
  count = var.create_s3 ? 1 : 0

  bucket = aws_s3_bucket.static_assets[0].id

  rule {
    object_ownership = var.s3_bucket_object_ownership
  }
}
resource "aws_s3_bucket_acl" "static_assets" {
  count = var.create_s3 ? 1 : 0

  depends_on = [aws_s3_bucket_ownership_controls.static_assets]
  bucket     = aws_s3_bucket.static_assets[0].id
  acl        = var.s3_bucket_acl
}
