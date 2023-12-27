output "bucket_name" {
  value = module.bucket.s3_bucket_id
}

output "region" {
  value = module.bucket.s3_bucket_region
}