variable default_tags {
  type = map(string)
  default = {
    Environment           = "kcoidc_test"
    tagging-version       = "0.0.1"
    stage                 = "TEST"
    project_name          = "KCOIDC"
  }
}
variable stage {
  default = "test"
  #defines the names of many things such as IAM roles, policies etc. Also the names of S3 buckets. Change with care.
}
variable env_name {
  default = "kcoidc"
  #defines the names of many things such as IAM roles, policies etc. Also the names of S3 buckets. Change with care.
}
variable root_dn {
  description = "Root domain name. If this is 'your.domain', the ec2 instance will get 'auth.your.domain'"
}
variable oidc_thumbprint {}
variable oidc_provider {}
variable client_id {
  description = "clientID of the client created by kcoidc.sh"
  default = "awsoidc"
}
variable group{
  description = "The name of the keycloak group to grant access to"
  default = "aws_access"
}

variable group2{
  description = "The name of the keycloak group to grant access to"
  default = "aws_access_exclusive"
}


