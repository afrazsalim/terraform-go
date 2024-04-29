variable "env_name" {
  type = string
  description = "Name of the vpc"
}

variable "vpc_cidr" {
  type = string 
  description = "CIDR range for the vpc"
}

variable "instance_type" {
  type = string
  description = "Type of the instnace"
  default = "t2.micro"
}

variable "ami" {
  type = string
  description = "AMI for the instance"
  default = "ami-0d421d84814b7d51c"
}
