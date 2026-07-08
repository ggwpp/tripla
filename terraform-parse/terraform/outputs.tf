output "cluster_name" {
  value = module.eks.cluster_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "s3_bucket_id" {
  value = var.create_s3 ? aws_s3_bucket.static_assets[0].id : null
}

output "s3_bucket_arn" {
  value = var.create_s3 ? aws_s3_bucket.static_assets[0].arn : null
}
