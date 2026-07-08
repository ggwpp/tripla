terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

locals {
  region    = "ap-northeast-1"
  create_s3 = false
}

provider "aws" {
  region = local.region
}


# This is account level setting and should not be in the module
resource "aws_s3_account_public_access_block" "allow_public_acl" {
  count = local.create_s3 ? 1 : 0

  block_public_acls       = "false"
  block_public_policy     = "true"
  ignore_public_acls      = "false"
  restrict_public_buckets = "true"
}

module "eks" {
  source = "../"

  cluster_name    = "tripla-messy-eks"
  cluster_version = "1.36"
  vpc_id          = "vpc-e879f68c"
  subnet_ids      = ["subnet-a4e8bcd2", "subnet-e18d1db9", "subnet-49ec9a61"]
  environment     = "dev"

  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["213.124.134.259/32"] # Replace with your public IPs

  eks_node_ami_type       = "BOTTLEROCKET_ARM_64"
  eks_node_instance_types = ["t4g.medium"]
  eks_node_group_name     = "general"
  eks_node_capacity_type  = "SPOT"
  eks_node_min_size       = 1
  eks_node_desired_size   = 1
  eks_node_max_size       = 3

  create_s3 = local.create_s3
}
