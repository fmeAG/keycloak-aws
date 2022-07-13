#!/bin/bash
source ./kcadm.sh

function prepareJson(){
  cat oidc_client.json | jq '.baseUrl="'"https://broker.${TF_VAR_root_dn}"'"' \
  | jq '.webOrigins=["'"https://broker.${TF_VAR_root_dn}"'"]' \
  | jq '.redirectUris=["'"https://broker.${TF_VAR_root_dn}/loggedout"'", "'"https://broker.${TF_VAR_root_dn}/oidc/callback"'"]' > "$1"
  
}
start
kcadm config credentials --server https://auth.${TF_VAR_root_dn} --realm master --user admin --password ${TF_VAR_keycloak_password}
createRealm
prepareJson kcadmvol/oidc_client.json

res="$(kcadm create clients -r ${REALM_NAME} -s clientId="awsoidc" -s enabled=true -f /shared/oidc_client.json)"

