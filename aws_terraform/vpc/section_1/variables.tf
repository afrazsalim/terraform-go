variable "vpc_cidr_block" {
   default = "10.0.0.0/16"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "key_name" {
    default = "my_key"
}

variable "ami_id" {
  type = map(string)
  default = {
    "eu-west-1" = "ami-07355fe79b493752d"
  }
}

