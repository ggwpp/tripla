variable "cluster_name" {
  type    = string
  default = "tripla-messy-eks"
}

variable "vpc_id" {
  type = string
  default = ""
}

variable "subnet_ids" {
  type = list(string)
  default = []
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "create_s3" {
  type = bool
  default = false
}

variable "s3_bucket_name" {
  type = string
  default = null

  validation {
    condition = var.create_s3 ? (var.s3_bucket_name != null && var.s3_bucket_name != "") : true
    error_message = "The `s3_bucket_name` must be set when create_s3 is true"
  }
}

variable "s3_bucket_object_ownership" {
  type = string
  default = "BucketOwnerPreferred"
}

variable "s3_bucket_acl" {
  type = string
  default = "public-read"
}
