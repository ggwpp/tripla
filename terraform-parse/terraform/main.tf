terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

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
      # use_custom_launch_template = false
      capacity_type              = "SPOT"

      min_size     = 2
      desired_size = 2
      max_size     = 3
    } 
  }  

  tags = {
    Environment = var.environment
  }
}

# resource "aws_s3_bucket" "static_assets" {
#   bucket = "tripla-static-assets"
#   acl    = "public-read"
#   tags = {
#     Env = var.environment
#   }
# }
