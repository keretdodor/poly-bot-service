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

module "vpc" {
  source = "./modules/common"

}

module "polybot" {
  source = "./modules/polybot"

  instance_type = "t3.micro"
  key_name      = "BECKS-stockholm-10/9/24"
  alias         = "beck.magvonim.site"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnets

}
module "yolo5" {
  source = "./modules/yolo5"

  instance_type = "t3.micro"
  key_name      = "BECKS-stockholm-10/9/24"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnets
}