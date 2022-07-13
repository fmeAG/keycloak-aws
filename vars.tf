variable hosted_zone_id {
  description = "Hosted zone ID (needs to exist beforehand)"
}

variable root_dn {
  description = "Root domain name. If this is 'your.domain', the ec2 instance will get 'auth.your.domain'"
}

variable mail {
  description = "e-mail address to use for certbot"
}

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

variable postgres_password {}

variable keycloak_password {}
