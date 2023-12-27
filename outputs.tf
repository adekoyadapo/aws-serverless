output "api_url" {
  value       = "${module.api_gateway.apigatewayv2_api_api_endpoint}/${var.api_path}"
  description = "The API endpoint to access the REST API"
}

output "S3_BUCKET_NAME" {
  value       = module.bucket.s3_bucket_id
  description = "s3 bucket name"
}

output "S3_JSON_FILE_NAME" {
  value       = module.s3_object.s3_object_id
  description = "the file name and extension uploaded to s3"
}

output "lambda_function_name" {
  value       = module.lambda_function.lambda_function_name
  description = "The lambda function name"
}