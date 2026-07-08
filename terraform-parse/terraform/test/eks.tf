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

  cluster_name = "tripla-messy-eks"
  vpc_id       = "vpc-e879f68c"
  subnet_ids   = ["subnet-a4e8bcd2", "subnet-e18d1db9", "subnet-49ec9a61"]
  environment  = "dev"

  create_s3 = local.create_s3
}
