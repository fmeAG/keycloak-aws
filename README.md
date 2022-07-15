# Keycloak on AWS for SAML and OIDC experiments
Provided by [fme AG](https://www.fme.de/dienstleistungen/technology-services/cloud-technologien/)<br/> 
![fmeLogo.png](fmeLogo.png "fme logo")<br/><br/>
This repo provides IaC that would deploy a keycloak server on AWS as well as scripts to set up rudimentary SAML and OIDC clients for AWS access federation.

## Compatibility
The repo has been tested to work with Keycloak 18.0.2 (which is currently distrubuted as `quay.io/keycloak/keycloak:latest`). The `latest` tag in `user_data/keycloak.sh` can be changed to a fixed version, if later releases will break the compatibility.

## Prerequisites
  - An [AWS account](https://aws.amazon.com) and working [AWS access key and secret](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
  - bash (if you want to run the scripts, at least)
  - [Terraform](https://www.terraform.io/downloads)
  - [jq](https://stedolan.github.io/jq/)
  - [docker](https://docs.docker.com/engine/install/) (or an alternative tool such as [podman](https://podman.io/getting-started/)). Alternatively, you can install java and run kcadm.sh directly.
  - The [terraform modules](https://github.com/konstl000/terraform-modules) repo cloned to `../terraform-modules`

## Preparing the environment
Before the deployment is possible, a few things need to be provided first

  - Create a hosted zone that controls a domain or a subdomain. To use keycloak as an OIDC IDP for AWS, a domain and a TLS certificate are needed. Terraform can create the corresponding route53 entry, if a hosted zone ID is provided. These [instructions](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html) can help with a hosted zone creation.
  - Create an export bash file (or export the corresponding variables manually)
```
cat<<EOF>export.sh
#!/bin/bash
export TF_VAR_hosted_zone_id='YOUR_HOSTED_ZONE_ID'
export TF_VAR_root_dn='YOUR DOMAIN OR SUBDOMAIN THAT IS CONTROLLED BY THE HOSTED ZONE ABOVE'
export TF_VAR_mail='yours@example.com'
export TF_VAR_postgres_password='some password'
export TF_VAR_keycloak_password='another password'
export KC_USER_PASSWORD='yet another password'
EOF
```
  Replace the placeholders with proper values and source the resulting file.

## Deployment
If you feel the need, you can adjust the instance size and other parameters in the .tf files.

```
source ./export.sh
./rsa.sh
terraform init
terraform plan -out plan
terraform apply plan
```

Shortly after the deployment is complete, keycloak should become accessible under `https://auth.${TF_VAR_root_dn}`. For instance, if your domain is `my.example.com`, then the keycloak address would be `https://auth.my.example.com`. A valid Let's encrypt certificate should be acquired automatically and available for this domain. **If you do not provide a valid domain controlled by you, the deployment will be incomplete and keycloak will not start properly**.

## Access to AWS with SAML
```
source ./export.sh
./kcsaml.sh
pushd aws-saml
terraform init
terraform plan -out plan
terraform apply plan
./kccommands.sh
```
 - Open the browser (I would recommend Google Chrome or something chromium-based). Press `F12` and go to the network tab.
 - Go to `https://auth.${TF_VAR_root_dn}/realms/awsfed/protocol/saml/clients/amazon-aws`. Login using `testuser` and `${KC_USER_PASSWORD}` (the value, you set as described above).
 - You should be redirected to the AWS console of your AWS account with ReadOnlyAccess rights. Of course, you can change the policy to whatever you want in `aws-saml/iam.tf`.
 - In the network tab of the browser developer tools, you should see the document called `saml`. Copy its value and save it as `assertion` (assuming your are still in `./aws-saml`)
 - Run `./saml.sh`. You should be able to assume the first role but not the second, because `testuser` does not have it assigned. This proves the point that AWS do check SAML assertions for the role you actually try to assume.

```
popd
```
## Access to AWS via OIDC
(Requires the scripts for SAML (above) to be executed first)
```
source ./export.sh
./kcoidc.sh
pushd aws-oidc
source ./thumb.sh
terraform init
terraform plan -out plan
terraform apply plan
./oidc.sh
```
In this case, you can assume the role straight away without anything assigned to `testuser` in keycloak. Compare this to the SAML case, where we had to run `./kccommands.sh` that creates a role and role mapping **after** running terraform.
Got you interested? Read the [upcoming blog post](https://content.fme.de/blog) to learn how to properly secure OIDC access to AWS.

## Fortified access to AWS via OIDC
(Assumes that the scripts from the previous section were executed)
```
./oidc_protected.sh
popd
```
In this case, you should be able to access the first but not the second role. This is because `testuser` is in the `aws_access` but not in the `aws_access_exclusive` group (which does not even exist yet).
Creating the group in the Keycloak admin console and assigning it to `testuser` fixes this.

## Cleanup
Assuming you are in the root folder of the repo,
```
pushd aws-saml
terraform destroy
popd
pushd aws-oidc
source ./thumb.sh
terraform destroy
popd
source ./export.sh
terraform destroy
```

