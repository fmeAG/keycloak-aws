resource "aws_route53_record" "edge" {
  zone_id = var.hosted_zone_id
  name    = "auth.${var.root_dn}"
  type    = "A"
  ttl     = "300"
  records = [module.vm.public_ip]
}

