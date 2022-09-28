#!/bin/bash
mkdir -p jar
docker run --rm -v $PWD/keycloak_provider:/src -v $PWD/jar:/providers bitnami/java:latest jar cvf /providers/prov.jar -C /src .
