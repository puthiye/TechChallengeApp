output "elb_dns_name" {
  value       = aws_elb.elb-sample.dns_name
  description = "The DNS of load balancer"
} 
