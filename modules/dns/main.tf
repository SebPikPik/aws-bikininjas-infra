# Create a hosted zone for the domain
resource "aws_route53_zone" "main" {
  name = var.domain_name
  comment = "Managed by Terraform for Minecraft server"
  
  tags = var.tags
}

# ACM Certificate for the domain
resource "aws_acm_certificate" "minecraft" {
  domain_name       = "${var.minecraft_subdomain}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# DNS validation record for the certificate
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.minecraft.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "minecraft" {
  certificate_arn         = aws_acm_certificate.minecraft.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# DNS record for the Minecraft server
resource "aws_route53_record" "minecraft" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "${var.minecraft_subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.nlb_dns_name
    zone_id                = var.nlb_zone_id
    evaluate_target_health = true
  }
}
