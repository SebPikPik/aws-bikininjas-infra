output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate_validation.minecraft.certificate_arn
}

output "domain_name" {
  description = "Full domain name for the Minecraft server"
  value       = "${var.minecraft_subdomain}.${var.domain_name}"
}

output "zone_id" {
  description = "Zone ID of the Route53 hosted zone"
  value       = data.aws_route53_zone.main.zone_id
}
