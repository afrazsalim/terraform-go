
output "s3_bucket" {
   description = "s3 bucket to store state: arn"
   value = aws_s3_bucket.tf_state_bucket.arn
}


