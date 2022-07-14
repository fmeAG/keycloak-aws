#!/bin/bash
currDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pushd "$currDir"
ROLE_ARN="$(terraform output -raw role_arn)"
PROVIDER_ARN="$(terraform output -raw provider_arn)"
ANOTHER_ROLE_ARN="$(terraform output -raw another_role_arn)"
echo "Trying the first role"
aws sts assume-role-with-saml --role-arn="${ROLE_ARN}" --principal-arn="${PROVIDER_ARN}" --saml-assertion="$(cat assertion)"
echo "Trying the second role"
aws sts assume-role-with-saml --role-arn="${ANOTHER_ROLE_ARN}" --principal-arn="${PROVIDER_ARN}" --saml-assertion="$(cat assertion)"
popd
