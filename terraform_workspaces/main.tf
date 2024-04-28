provider "aws" {
   region = "eu-west-1"
}


data "aws_vpc" "default" {
   default = true
}


resource "aws_instance" "ec2" {
  instance_type = terraform.workspace == "default" ? "t2.micro" : "t2.micro"
  ami = "ami-0d421d84814b7d51c"
  
}

resource "aws_s3_bucket" "tf_state_bucket" {
   bucket = "test-tf-state-bucket-eus"

   lifecycle {
     prevent_destroy = false
   }
}

resource "aws_s3_bucket_versioning" "versioning" {
   bucket = aws_s3_bucket.tf_state_bucket.id
   versioning_configuration {
     status = "Enabled"
   }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
   bucket = aws_s3_bucket.tf_state_bucket.id

   rule {
     apply_server_side_encryption_by_default {
       sse_algorithm = "AES256"
     }
   }
}

resource "aws_s3_bucket_public_access_block" "bucket_policy" {
   bucket = aws_s3_bucket.tf_state_bucket.id
   block_public_acls = true
   block_public_policy = true 
   ignore_public_acls = true 
   restrict_public_buckets = true 
}

resource "aws_dynamodb_table" "tf_state_tables" {
   name = "tf_state_table"
   billing_mode = "PAY_PER_REQUEST"
   hash_key = "LockID"

   attribute {
     name = "LockID"
     type = "S"
   }
}

terraform {
    backend "s3" {
    bucket = "test-tf-state-bucket-eus"
    key = "key/tfstate"
    region = "eu-west-1"

    dynamodb_table = "tf_state_table"
    encrypt = true
  }
}