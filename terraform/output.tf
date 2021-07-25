output "mediawiki_url" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.external-elb.dns_name
}