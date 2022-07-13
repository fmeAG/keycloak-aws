#!/bin/bash
#!/bin/bash
ROLE_ARN="$(terraform output -raw role_arn)"
PROVIDER_ARN="$(terraform output -raw provider_arn)"
ANOTHER_ROLE_ARN="$(terraform output -raw another_role_arn)"
aws sts assume-role-with-saml --role-arn="${ROLE_ARN}" --principal-arn="${PROVIDER_ARN}" --saml-assertion="$(cat assertion)"

aws sts assume-role-with-saml --role-arn="${ANOTHER_ROLE_ARN}" --principal-arn="${PROVIDER_ARN}" --saml-assertion="$(cat assertion)"

