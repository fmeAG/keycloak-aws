module "vm" {
  source = "../terraform-modules/modules/ec2"
  ami = data.aws_ami.amazon-linux-2.id
  server_name = "keycloak"
  instance_type = "t3.medium"
  volume_size = 20
  vpc_id = module.vpc.vpc_id
  subnet = module.vpc.public_subnets.0
  ssh_public_keys = [file("./rsa/kc.pem.pub")]
  ssh_key_name = "KeyCloak"
  security_groups = [module.keycloak_sg.id]
  role = module.instance_role.name
  default_tags = var.default_tags
  instance_profile_name = "${upper(var.env_name)}_${upper(var.stage)}_Keycloak"
  persistent_volume_size = 20
  additional_tools = ["docker"]
  additional_user_data = [
    {
      filename     = "2-custom.sh"
      content_type = "text/x-shellscript"
      content      = data.template_file.keycloak.rendered
    },
    {
      filename     = "3-ssm.sh"
      content_type = "text/x-shellscript"
      content      = file("./user_data/ssm.sh")
    }
  ]
}

