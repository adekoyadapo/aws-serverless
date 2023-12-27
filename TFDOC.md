<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.10.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.10.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_api_gateway"></a> [api\_gateway](#module\_api\_gateway) | terraform-aws-modules/apigateway-v2/aws | ~> 2.2.2 |
| <a name="module_bucket"></a> [bucket](#module\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 3.14.1 |
| <a name="module_lambda_function"></a> [lambda\_function](#module\_lambda\_function) | terraform-aws-modules/lambda/aws | 5.3.0 |
| <a name="module_s3_object"></a> [s3\_object](#module\_s3\_object) | terraform-aws-modules/s3-bucket/aws//modules/object | ~> 3.14.1 |
| <a name="module_security_group_lambda"></a> [security\_group\_lambda](#module\_security\_group\_lambda) | terraform-aws-modules/security-group/aws | ~> 4.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.1.1 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | ~> 5.1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.lambda_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.sto-lambda-vpc-role-policy-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ec2_managed_prefix_list.prefix](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_managed_prefix_list) | data source |
| [aws_iam_policy.LambdaVPCAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_path"></a> [api\_path](#input\_api\_path) | The rest API path | `string` | `"api/bucket"` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | Availability zones last character, example a, b, c | `list(string)` | <pre>[<br>  "a",<br>  "b"<br>]</pre> | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | VPC cidr | `string` | `"10.0.0.0/16"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Resource region | `string` | `"ca-central-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_S3_BUCKET_NAME"></a> [S3\_BUCKET\_NAME](#output\_S3\_BUCKET\_NAME) | s3 bucket name |
| <a name="output_S3_JSON_FILE_NAME"></a> [S3\_JSON\_FILE\_NAME](#output\_S3\_JSON\_FILE\_NAME) | the file name and extension uploaded to s3 |
| <a name="output_api_url"></a> [api\_url](#output\_api\_url) | The API endpoint to access the REST API |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | The lambda function name |
<!-- END_TF_DOCS -->