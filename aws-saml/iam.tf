module "admin_role" {
  source = "../../terraform-modules/modules/iam_roles"
  default_tags = var.default_tags
  max_session_duration = 43200
  trust_policy = jsonencode(
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_saml_provider.kc.arn}" 
      },
      "Action": "sts:AssumeRoleWithSAML",
      "Condition": {
        "StringEquals": {
          "saml:aud": "https://signin.aws.amazon.com/saml"
        }
      }
    }
  ]
}
  )
  role_name = "${upper(var.env_name)}_${upper(var.stage)}_Federated_Admin-SAML"
  policy_arns=["arn:aws:iam::aws:policy/ReadOnlyAccess"]
}


module "another_role" {
  source = "../../terraform-modules/modules/iam_roles"
  default_tags = var.default_tags
  max_session_duration = 43200
  trust_policy = jsonencode(
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_saml_provider.kc.arn}"
      },
      "Action": "sts:AssumeRoleWithSAML",
      "Condition": {
        "StringEquals": {
          "saml:aud": "https://signin.aws.amazon.com/saml"
        }
      }
    }
  ]
}
  )
  role_name = "${upper(var.env_name)}_${upper(var.stage)}_Federated_Admin-SAML2"
  policy_arns=["arn:aws:iam::aws:policy/ReadOnlyAccess"]
}

