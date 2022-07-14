#!/bin/bash
exec >>/home/ec2-user/custom_log.txt
exec 2>&1
#get the TLS cert for keycloak
MAX_ATTEMPTS=20
INTERVAL=60
DB_INTERVAL=5
function checkDNS(){
  counter=1
  selfIP="$(curl 169.254.169.254/latest/meta-data/public-ipv4)"
  if [[ "$selfIP" == "" ]]
  then
    echo "Something is really wrong"
    exit 1
  fi
  while true
  do
    probe=$(dig "${DOMAIN}" @8.8.8.8 | grep "$selfIP")
    if [[ $probe != "" ]]
    then
      echo "DNS check OK"
      break
    else
      if [[ $counter -gt $MAX_ATTEMPTS ]]
      then
        echo "DNS check failed!"
        exit 1
      fi
      echo "${DOMAIN} is not assigned to $selfIP, waiting for $INTERVAL seconds ..."
      counter=$((counter+1))
      sleep $INTERVAL
    fi
  done
}

function createDatabase(){
  counter=1
  while true
  do
    docker exec psql bash -c "su - postgres bash -c 'psql -c "'"'"CREATE DATABASE keycloak"'"'"'"
    if [[ $? == 0 ]]
    then
      echo "DB created successfully"
      break
    else
      if [[ $counter -gt $MAX_ATTEMPTS ]]
      then
        echo "DB creation failed!"
        exit 1
      fi
      echo "Could not create a new DB, waiting for $DB_INTERVAL seconds ..."
      counter=$((counter+1))
      sleep $DB_INTERVAL
    fi
  done 
}

checkDNS

mkdir -p /home/persistent/le
mkdir -p /home/persistent/le2
docker run --name certbot \
            -v "/home/persistent/le:/etc/letsencrypt" \
            -v "/home/persistent/le2:/var/lib/letsencrypt" \
            -p 80:80 \
            certbot/certbot certonly --standalone --non-interactive --agree-tos -m ${MAIL} -d ${DOMAIN}

#Create a docker network
docker network create kc --ip-range 172.20.0.0/24 --subnet 172.20.0.0/16 --gateway 172.20.0.1
#Start a postgres database
docker run -d -e POSTGRES_PASSWORD='${POSTGRES_PASSWORD}' --name psql --network kc --ip 172.20.0.2 postgres:latest
#Create a database for keycloak
createDatabase

#Copy the files and thus resolve the symlinks
mkdir -p /home/persistent/keycloak/tls
cp /home/persistent/le/live/${DOMAIN}/fullchain.pem /home/persistent/keycloak/tls/
cp /home/persistent/le/live/${DOMAIN}/cert.pem /home/persistent/keycloak/tls/
cp /home/persistent/le/live/${DOMAIN}/privkey.pem /home/persistent/keycloak/tls/
#Make the keycloak user able to access the cert and the key
chown -R 1000 /home/persistent/keycloak/tls/
pushd /home/persistent/keycloak
#Create an env file for the keycloak container
cat<<EOF>envfile
KC_DB=postgres
KC_DB_URL=jdbc:postgresql://172.20.0.2/keycloak
KC_DB_USERNAME=postgres
KC_DB_PASSWORD=${POSTGRES_PASSWORD}
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=${KEYCLOAK_PASSWORD}
KC_HOSTNAME=${DOMAIN}
KC_HTTPS_CERTIFICATE_FILE=/tls/fullchain.pem
KC_HTTPS_CERTIFICATE_KEY_FILE=/tls/privkey.pem
KC_HTTPS_PORT=443
KC_HTTP_ENABLED=true
EOF
mkdir -p providers
echo '${JAR}' | base64 -d > providers/prov.jar

docker run --network=kc \
  --ip=172.20.0.3 -d \
  --name keycloak \
  --env-file=envfile \
  -p 443:443 \
  -v "/home/persistent/keycloak/tls:/tls" \
  -v $PWD/providers:/opt/keycloak/providers \
  --hostname="${DOMAIN}" \
  --entrypoint=/bin/bash \
  quay.io/keycloak/keycloak:latest \
  -c '/opt/keycloak/bin/kc.sh start --auto-build -Dkeycloak.profile=preview'
popd
