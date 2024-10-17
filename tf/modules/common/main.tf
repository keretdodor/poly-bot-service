module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "polybot-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available_azs.names
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  map_public_ip_on_launch = true
  

  enable_nat_gateway = false
}

resource "aws_sqs_queue" "polybot-queue" {
  name                      = "poly-bot-queue"
}

resource "aws_dynamodb_table" "polybot-table" {
  name           = "polybotWOW"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "prediction_id"
  attribute {
        name = "prediction_id"
        type = "S"
    }
}
