output role_arn {
  value = module.admin_role.arn
}
output another_role_arn {
  value = module.another_role.arn
}

output provider_arn {
  value = aws_iam_saml_provider.kc.arn  
}
