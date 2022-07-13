resource "aws_iam_openid_connect_provider" "oidc" {
  url = "https://${var.oidc_provider}"

  client_id_list = [
    var.client_id
  ]
  thumbprint_list = [var.oidc_thumbprint]
}

