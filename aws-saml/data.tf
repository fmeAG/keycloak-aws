data "http" "saml" {
  url = "https://auth.${var.root_dn}/realms/awsfed/protocol/saml/descriptor"

  # Optional request headers
  request_headers = {
    Accept = "application/xml"
  }
}
