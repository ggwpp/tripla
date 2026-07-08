variable "cluster_name" {
  type    = string
  default = "tripla-messy-eks"
}

variable "cluster_version" {
  type    = string
  default = "1.33"
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "cluster_endpoint_private_access" {
  type    = bool
  default = true
}

variable "cluster_endpoint_public_access" {
  type    = bool
  default = false
}

variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = []
}

variable "eks_node_ami_type" {
  type    = string
  default = "AL2023_x86_64_STANDARD"
}

variable "eks_node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "eks_node_group_name" {
  type    = string
  default = "general"
}

variable "eks_node_capacity_type" {
  type    = string
  default = "SPOT"
}

variable "eks_node_min_size" {
  type    = number
  default = 1
}

variable "eks_node_desired_size" {
  type    = number
  default = 1
}

variable "eks_node_max_size" {
  type    = number
  default = 3
}

variable "create_s3" {
  type    = bool
  default = false
}

variable "s3_bucket_name" {
  type    = string
  default = null

  validation {
    condition     = var.create_s3 ? (var.s3_bucket_name != null && var.s3_bucket_name != "") : true
    error_message = "The `s3_bucket_name` must be set when create_s3 is true"
  }
}

variable "s3_bucket_object_ownership" {
  type    = string
  default = "BucketOwnerPreferred"
}

variable "s3_bucket_acl" {
  type    = string
  default = "public-read"
}
