#!/bin/bash
source ../kcadm.sh
function main(){
  local jwks_uri="$(curl -sSL https://auth.${TF_VAR_root_dn}/realms/${REALM_NAME}/.well-known/openid-configuration | jq -r '.jwks_uri' | cut -d '/' -f3)"
  timeout 3 openssl s_client -servername "$jwks_uri" -showcerts -connect "$jwks_uri":443 > cert.txt
  tac < cert.txt | sed '/END CERTIFICATE/,$!d;/BEGIN CERTIFICATE/q' | tac > cert.pem
  finger=$(openssl x509 -in cert.pem -fingerprint -noout | sed -e 's/^.*=//' -e 's/://g' | tr '[:upper:]' '[:lower:]' )
  rm cert.txt
  rm cert.pem
  export TF_VAR_oidc_thumbprint="$finger"
  export TF_VAR_oidc_provider="auth.${TF_VAR_root_dn}/realms/${REALM_NAME}"
}
main

