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
  region = "ap-northeast-1"
}

provider "aws" {
  region = local.region
}

module "eks" {
  source = "../"

  cluster_name = "tripla-messy-eks"
  vpc_id       = "vpc-e879f68c"
  subnet_ids   = ["subnet-a4e8bcd2", "subnet-e18d1db9", "subnet-49ec9a61"]
  environment  = "dev"
}
