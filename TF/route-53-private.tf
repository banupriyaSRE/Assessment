resource "aws_route53_zone" "route53_private_domain" {
  name = var.route53_private_domain

  vpc {
    vpc_id = aws_vpc.Application-Plane-VPC.id
  }

  tags = {
    Name        = "${var.app_name}-${var.app_environment}-domain"
    Environment = var.app_environment
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.route53_private_domain.zone_id
  name    = var.route53_private_domain
  type    = "A"

  alias {
    name                   = aws_lb.external-elb.dns_name
    zone_id                = aws_lb.external-elb.zone_id
    evaluate_target_health = true
  }
}