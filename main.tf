data "aws_region" "current" {}

data "aws_ec2_managed_prefix_list" "prefix" {
  name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

# VPC 
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  version                     = "~> 5.1.1"
  name                        = "vpc-${random_string.suffix.result}"
  cidr                        = var.cidr
  azs                         = [for i in toset(var.azs) : "${data.aws_region.current.name}${i}"]
  intra_subnets               = [for i in toset(var.azs) : cidrsubnet(var.cidr, 8, index(var.azs, i))]
  intra_dedicated_network_acl = true
  intra_inbound_acl_rules = concat(
    # NACL rule for local traffic
    [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "10.0.0.0/16"
      },
    ],
    # NACL rules for the response traffic from addresses in the AWS S3 prefix list
    [for k, v in zipmap(
      range(length(data.aws_ec2_managed_prefix_list.prefix.entries[*].cidr)),
      data.aws_ec2_managed_prefix_list.prefix.entries[*].cidr
      ) :
      {
        rule_number = 200 + k
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = v
      }
    ]
  )
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.1.1"

  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.intra_route_table_ids
    }
  }
}

module "security_group_lambda" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "lambda-sg-${random_string.suffix.result}"
  description = "Security Group for Lambda Egress"

  vpc_id = module.vpc.vpc_id

  egress_cidr_blocks      = []
  egress_ipv6_cidr_blocks = []

  # Prefix list ids to use in all egress rules in this module
  egress_prefix_list_ids = [module.vpc_endpoints.endpoints["s3"]["prefix_list_id"]]

  egress_rules = ["https-443-tcp"]
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
}

# bucket
module "bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "~> 3.14.1"
  bucket        = "json-bucket-${random_string.suffix.result}"
  force_destroy = true
}

module "s3_object" {
  source        = "terraform-aws-modules/s3-bucket/aws//modules/object"
  version       = "~> 3.14.1"
  bucket        = module.bucket.s3_bucket_id
  key           = "json-bucket-${random_string.suffix.result}.json"
  content       = <<EOF
{
  "greeting": "I am the Foo"
}
EOF
  content_type  = "application/json"
  force_destroy = true
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "LambdaS3ENIAccessPolicy"
  description = "IAM policy for Lambda to read S3 and create ENI"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "${module.bucket.s3_bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:CreateTags"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = module.lambda_function.lambda_role_name
}

# lambda
module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  version = "5.3.0"

  function_name = "lambda-${random_string.suffix.result}"
  description   = "lambda function to read contents of a bucket file"
  handler       = "app.lambda_handler"
  runtime       = "python3.10"
  environment_variables = {
    S3_BUCKET_NAME    = module.bucket.s3_bucket_id
    S3_JSON_FILE_NAME = module.s3_object.s3_object_id
  }
  attach_cloudwatch_logs_policy = false
  create_role                   = true

  source_path = "${path.module}/app/"

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*/*"
    }
  }
  publish = true

  tags = {
    Name = "lambda-${random_string.suffix.result}"
  }
  vpc_security_group_ids = [module.security_group_lambda.security_group_id]
  vpc_subnet_ids         = module.vpc.intra_subnets
}

data "aws_iam_policy" "LambdaVPCAccess" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "sto-lambda-vpc-role-policy-attach" {
  role       = module.lambda_function.lambda_role_name
  policy_arn = data.aws_iam_policy.LambdaVPCAccess.arn
}

# API gateway

module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 2.2.2"

  name                   = "apigw-${random_string.suffix.result}"
  description            = "API GW to Lambda function"
  protocol_type          = "HTTP"
  create_api_domain_name = false
  route_key              = "GET /${var.api_path}"
  target                 = module.lambda_function.lambda_function_arn

  create_default_stage = false

  tags = {
    Name = "http-apigateway-${random_string.suffix.result}"
  }
}