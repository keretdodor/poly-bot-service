terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.55"
    }
  }

  required_version = ">= 1.7.0"

  backend "s3" {
    bucket = "dork-tf-state"
    key    = "tfstate.json"
    region = "eu-north-1"

  }

}
provider "aws" {
  region = "eu-north-1"
}

module "common" {
  source            = "./modules/common"
  sqs_queue_name    = "wowo-poly"
  dynamo_table_name = "polybot-table-s"
  bucket_name       = "becksboys-ganggang"

}

module "polybot" {
  source = "./modules/polybot"

  instance_type = "t3.micro"
  key_name      = "BECKS-stockholm-10/9/24"
  alias_record  = "polypol.magvonim.site"
  vpc_id        = module.common.vpc_id
  subnet_id     = module.common.public_subnets

}
module "yolo5" {
  source = "./modules/yolo5"

  instance_type = "t3.micro"
  key_name      = "BECKS-stockholm-10/9/24"
  vpc_id        = module.common.vpc_id
  subnet_id     = module.common.public_subnets
}