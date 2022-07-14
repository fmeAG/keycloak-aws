#!/bin/bash
GROUP_NAME="aws_access"
source ../kcadm.sh

start
kcadm config credentials --server https://auth.${TF_VAR_root_dn} --realm master --user admin --password ${TF_VAR_keycloak_password}
clientId="$(getClientId 'urn:amazon:webservices')"
res=$(kcadm create groups -r ${REALM_NAME} -s name="${GROUP_NAME}")
groupId="$(echo "$res" | sed -e 's/^.* //' -e 's/'"'"'//g' -e 's/\r//g')" #keycloak provides the damn carriage return too, which fucks up the complex strings if not removed
kcadm create "clients/$clientId/roles" -r ${REALM_NAME} -s "name=$(terraform output -raw role_arn),$(terraform output -raw provider_arn)" -s 'description=AWS Access'
kcadm add-roles -r ${REALM_NAME} --gname "${GROUP_NAME}" --cclientid 'urn:amazon:webservices'  --rolename "$(terraform output -raw role_arn),$(terraform output -raw provider_arn)"
res=$(kcadm create users -r ${REALM_NAME} -s username=testuser -s email=test@fme.de -s enabled=true)
userId="$(echo "$res" | sed -e 's/^.* //' -e 's/'"'"'//g' -e 's/\r//g')"
kcadm update "users/$userId/reset-password" -r ${REALM_NAME} -s type=password -s "value=${KC_USER_PASSWORD}" -s temporary=false -n
kcadm update "users/$userId/groups/$groupId" -r ${REALM_NAME} -s "realm=${REALM_NAME}" -s "userId=$userId" -s "groupId=$groupId" -n
