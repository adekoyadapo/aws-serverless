resource "random_string" "suffix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
}

# resource "aws_kms_key" "terraform-bucket-key" {
#  description             = "This key is used to encrypt bucket objects"
#  deletion_window_in_days = 10
#  enable_key_rotation     = true
# }

# resource "aws_kms_alias" "key-alias" {
#  name          = "alias/terraform-bucket-key"
#  target_key_id = aws_kms_key.terraform-bucket-key.key_id
# }
module "bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.14.1"
  bucket  = "terraform-state-${random_string.suffix.result}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  force_destroy = true
  # server_side_encryption_configuration = {

  #   rule = {
  #     apply_server_side_encryption_by_default = {
  #       kms_master_key_id = aws_kms_key.terraform-bucket-key.arn
  #       sse_algorithm     = "aws:kms"
  #     }
  #   }
  # }

  versioning = {
    status     = true
    mfa_delete = false
  }
}

# terraform {
#  backend "s3" {
#    bucket         = "<BUCKET_NAME>" # update with the output of the bucket name
#    key            = "backend/terraform.tfstate" 
#    region         = "ca-central-1" 
# #    encrypt        = true
# #    kms_key_id     = "alias/terraform-bucket-key"
#  }
# }