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
        "Federated": aws_iam_openid_connect_provider.oidc.arn
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${var.oidc_provider}:aud": var.client_id
        }
      }
    }
  ]
}
  )
  role_name = "${upper(var.env_name)}_${upper(var.stage)}_OIDC_Role"
  policy_arns=["arn:aws:iam::aws:policy/ReadOnlyAccess"]
}
module "protected_role" {
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
        "Federated": aws_iam_openid_connect_provider.oidc.arn 
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${var.oidc_provider}:aud": var.client_id
        },
        "StringLike":{
          "${var.oidc_provider}:sub": ["*-${var.group}-*"]
        }
      }
    }
  ]
}
  )
  role_name = "${upper(var.env_name)}_${upper(var.stage)}_OIDC_Role_Protected"
  policy_arns=["arn:aws:iam::aws:policy/ReadOnlyAccess"]
}
module "protected_role2" {
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
        "Federated": aws_iam_openid_connect_provider.oidc.arn 
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${var.oidc_provider}:aud": var.client_id
        },
        "StringLike":{
          "${var.oidc_provider}:sub": ["*-${var.group2}-*"]
        }
      }
    }
  ]
}
  )
  role_name = "${upper(var.env_name)}_${upper(var.stage)}_OIDC_Role_Protected2"
  policy_arns=["arn:aws:iam::aws:policy/ReadOnlyAccess"]
}

