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
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids

  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  eks_managed_node_group_defaults = {
    ami_type       = var.eks_node_ami_type
    instance_types = var.eks_node_instance_types
  }

  eks_managed_node_groups = {
    (var.eks_node_group_name) = {
      capacity_type = var.eks_node_capacity_type

      min_size     = var.eks_node_min_size
      desired_size = var.eks_node_desired_size
      max_size     = var.eks_node_max_size
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
  count  = var.create_s3 ? 1 : 0
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
