
variable "instance_type" {
   description = "Instance Type"
   type        = string
}

variable "key_name" {
   description = "key name"
   type        = string
}
variable "subnet_id" {
  type        = list(string)
  description = "List of subnets from the VPC module"
}

variable "vpc_id" {
  type        = string
  description = "The vpc id"
}

variable "dynamodb_table_name" {
   description = "table's name"
   type        = string
}

variable "sqs_queue_name" {
   description = "sqs name"
   type        = string
}
variable "bucket_name" {
   description = "bucket name"
   type        = string
}

variable "alias_record" {
  type        = string
  description = "The full alias record"
}
