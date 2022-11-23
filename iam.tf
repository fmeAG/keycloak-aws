module "instance_role" {
  role_name = "${upper(var.env_name)}_${upper(var.stage)}_keycloak"
  source = "../terraform-modules/modules/iam_roles"
  default_tags = var.default_tags
  service = "ec2.amazonaws.com"
}
resource "aws_iam_policy" "ssm_policy" {
        name = "Session_manager_access_i8vQIA8"
        policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:GetDeployablePatchSnapshotForInstance",
                "ssm:GetDocument",
                "ssm:DescribeDocument",
                "ssm:GetManifest",
                "ssm:GetParameters",
                "ssm:ListAssociations",
                "ssm:ListInstanceAssociations",
                "ssm:PutInventory",
                "ssm:PutComplianceItems",
                "ssm:PutConfigurePackageResult",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation"
            ],
            "Resource": "${module.vm.instance_arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
                ],
             "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetEncryptionConfiguration"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2messages:GetMessages",
                "ec2messages:AcknowledgeMessage",
                "ec2messages:SendReply"
            ],
            "Resource": "*"
        }
     ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "ssm_web" {
    role       = module.instance_role.name
    policy_arn = aws_iam_policy.ssm_policy.arn
}

