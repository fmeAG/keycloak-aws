#!/bin/bash
source ../kcadm.sh
function getClient(){
  kcadm get clients -r ${REALM_NAME} #| jq '.[] | select(.clientId=="'"$1"'")'
}
start
kcadm config credentials --server https://auth.${TF_VAR_root_dn} --realm master --user admin --password ${TF_VAR_keycloak_password}

getClient 'urn:amazon:webservices'

