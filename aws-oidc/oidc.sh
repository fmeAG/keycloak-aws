#!/bin/bash
source ../kcadm.sh
USERNAME="testuser"
CLIENT_ID="awsoidc"
function getClientSecret(){
  kcadm get -r ${REALM_NAME} "clients/$(getClientId ${1})/client-secret" | jq -r '.value'
}

function getToken(){
curl -X POST "${KEYCLOAK_URL}/realms/${REALM_NAME}/protocol/openid-connect/token" \
 -H "Content-Type: application/x-www-form-urlencoded" \
 -d "username=${USERNAME}" \
 -d "password=${KC_USER_PASSWORD}" \
 -d 'grant_type=password' \
 -d "client_id=${CLIENT_ID}" \
 -d "client_secret=${CLIENT_SECRET}" \
 -d 'scope=openid' | jq -r '.id_token'
}

start
kcadm config credentials --server https://auth.${TF_VAR_root_dn} --realm master --user admin --password ${TF_VAR_keycloak_password}

CLIENT_SECRET="$(getClientSecret $CLIENT_ID)"
ROLE_ARN="$(terraform output -raw role_arn)"
aws sts assume-role-with-web-identity --role-arn ${ROLE_ARN} --role-session-name foo --web-identity-token=$(getToken)
