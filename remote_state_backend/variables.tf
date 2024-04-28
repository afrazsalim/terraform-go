

variable "allowed_port" {
    description = "Allowed port for HTTP"
    type = string
    default = "8080"
}


variable "region" {
   description = "Region where infrastructure is being spawned"
   type = string
   default = "eu-west-1"
}