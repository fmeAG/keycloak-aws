module "vpc" {
  source = "../terraform-modules/modules/vpc"
  nat-subnet      = 0
  use-nat = false
  default_tags = var.default_tags
  cidr_range = "10.100.0.0/16"
  private_subnet_cidrs = {
        0 = "10.100.1.0/24"
        1 = "10.100.2.0/24"
        2 = "10.100.3.0/24"
  }
  public_subnet_cidrs = {
        0 = "10.100.10.0/24"
        1 = "10.100.11.0/24"
        2 = "10.100.12.0/24"
  }
  private2public = true
}

