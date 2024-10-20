variable "aws_region" {
  type    = string
  default = "eu-north-1" # eu-north-1 Stockholm
}

variable "s3_bucket_name" {
  type = string
}

variable "dynamodb_table_name" {
  type = string
}
