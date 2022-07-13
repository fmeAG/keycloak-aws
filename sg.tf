module "keycloak_sg"{
  source = "../terraform-modules/modules/sg"
  name = "keycloak-sg"
  description = "Allow traffic to the Keycloak instances"
  vpc_id = module.vpc.vpc_id
  rules = [
  jsonencode({
    type = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    source_security_group_id = null
  }),
  jsonencode({
    type = "ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }),
  jsonencode({
    type = "ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  })

]
  tags = merge({
  "Name" = "SG Keycloak"
},var.default_tags)
}

