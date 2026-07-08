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
