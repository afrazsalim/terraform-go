provider "aws" {
  region = "eu-west-1"
}

module "MyStageModule" {
  source = "../services/"
  env_name = "stage"
  vpc_cidr = "10.0.0.0/16"
}