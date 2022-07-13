resource "aws_iam_saml_provider" "kc" {
  name                   = "kcdemo"
  saml_metadata_document = data.http.saml.response_body
}
