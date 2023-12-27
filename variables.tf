variable "region" {
  description = "AWS Resource region"
  type        = string
  default     = "ca-central-1"
}

variable "api_path" {
  description = "The rest API path"
  type        = string
  default     = "api/bucket"
}

variable "cidr" {
  description = "VPC cidr"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones last character, example a, b, c"
  type        = list(string)
  default     = ["a", "b"]
}