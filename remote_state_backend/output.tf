output "dnsName" {
   description = "DNS name"
   value = aws_lb.appLB.dns_name
}

output "s3_bucket" {
   description = "s3 bucket to store state: arn"
   value = aws_s3_bucket.tf_state_bucket.arn
}


