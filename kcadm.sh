#!/bin/bash

#Let's use docker instead of directly using java
KEYCLOAK_URL="https://auth.${TF_VAR_root_dn}"
REALM_NAME="awsfed"
function start(){
  mkdir -p kcadmvol
  docker inspect kcadm >/dev/null 2>/dev/null
  if [[ $? -eq 0 ]]
  then
    docker start kcadm
  else  
    docker run --name kcadm -v $PWD/kcadmvol:/shared -d --entrypoint /bin/bash quay.io/keycloak/keycloak:latest -c 'tail -f /dev/null'
  fi
}

function kcadm(){
  docker exec -it kcadm /opt/keycloak/bin/kcadm.sh "$@"
}

function createRealm(){
  kcadm create realms -s realm="$REALM_NAME" -s enabled=true
}

function getClientJson(){
  TOKEN_URL="${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token"
  AUTH="Authorization: bearer $(curl -H "Content-Type: application/x-www-form-urlencoded" -d client_id=admin-cli -d username=admin --data-urlencode "password=${TF_VAR_keycloak_password}" -d grant_type=password ${TOKEN_URL} | jq -r '.access_token')"
  echo "$AUTH"
  CONVERTER_URL="${KEYCLOAK_URL}/admin/realms/$REALM_NAME/client-description-converter"
  curl -L -o aws.xml https://signin.aws.amazon.com/static/saml-metadata.xml
  CLIENT_JSON=$(curl -X POST -H "${AUTH}"  -H 'content-type: application/json' ${CONVERTER_URL} --data-binary @aws.xml)
  rm aws.xml
  echo "$(addMappersToClient "$CLIENT_JSON")" > "$1"
}

function upsert(){
  if [[ "$2" == null ]]
  then
    echo "$1" |  jq '.protocolMappers +=['"$3"']'
  else
    echo "$1" |  jq '.protocolMappers['$2']='"$3"
  fi
}

function addMappersToClient(){
#the definitions for Role and RoleSessionName from the XML are not quite correct, so they need to be overwritten
  awsRoleIndex="$(echo "$1" | jq -r '.protocolMappers | to_entries[] | select(.value.name=="https://aws.amazon.com/SAML/Attributes/Role") | .key')"
  sessionNameIndex="$(echo "$1" | jq -r '.protocolMappers | to_entries[] | select(.value.name=="https://aws.amazon.com/SAML/Attributes/RoleSessionName") | .key')"
  res="$(upsert "$1" $sessionNameIndex '{"name":"Session Name","protocol":"saml","protocolMapper":"saml-user-property-mapper","consentRequired":false,"config":{"attribute.nameformat":"Basic","user.attribute":"username","friendly.name":"Session Name","attribute.name":"https://aws.amazon.com/SAML/Attributes/RoleSessionName"}}')"
  res="$(upsert "$res" $awsRoleIndex '{"name":"Session Role","protocol":"saml","protocolMapper":"saml-role-list-mapper","consentRequired":false,"config":{"single":"true","attribute.nameformat":"Basic","friendly.name":"https://aws.amazon.com/SAML/Attributes/Role","attribute.name":"https://aws.amazon.com/SAML/Attributes/Role"}}')"
  echo "$res" | jq '.protocolMappers +=[{"name":"https://aws.amazon.com/SAML/Attributes/SessionDuration","protocol":"saml","protocolMapper":"saml-hardcode-attribute-mapper","consentRequired":false,"config":{"attribute.value":"43200","attribute.nameformat":"Basic","friendly.name":"Session Duration","attribute.name":"https://aws.amazon.com/SAML/Attributes/SessionDuration"}}]' | jq '.baseUrl="/realms/'"$REALM_NAME"'/protocol/saml/clients/amazon-aws"' | jq '.attributes.saml_idp_initiated_sso_url_name="amazon-aws"' | jq '.fullScopeAllowed=false' | jq '.defaultClientScopes=[]' 
}
function getClientId(){
  kcadm get clients -r ${REALM_NAME} | jq -r '.[] | select(.clientId=="'"$1"'") | .id'
}
