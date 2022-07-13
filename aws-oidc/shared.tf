provider "aws" {
  region     = "eu-central-1"
}
data "aws_region" "current" {
}
data "aws_caller_identity" "current" {}

data "aws_ami" "amazon-linux-2" {
 most_recent = true
 owners = ["amazon"]
 name_regex = "^amzn2-ami-hvm.*x86_64.*gp2$"
 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }


 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*x86_64*gp2"]
 }
}

