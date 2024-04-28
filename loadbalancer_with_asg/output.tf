output "dnsName" {
   description = "DNS name"
   value = aws_lb.appLB.dns_name
}