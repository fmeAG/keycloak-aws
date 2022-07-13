#!/bin/bash
source ./kcadm.sh

start
kcadm config credentials --server https://auth.${TF_VAR_root_dn} --realm master --user admin --password ${TF_VAR_keycloak_password}
createRealm
getClientJson kcadmvol/aws.json
kcadm create clients -r ${REALM_NAME} -s clientId="urn:amazon:webservices" -s enabled=true -f /shared/aws.json

