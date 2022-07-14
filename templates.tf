data "template_file" "keycloak" {
  template= file("./user_data/keycloak.sh")
  vars = {
    DOMAIN = "auth.${var.root_dn}"
    MAIL = var.mail
    POSTGRES_PASSWORD = var.postgres_password
    KEYCLOAK_PASSWORD = var.keycloak_password
    JAR               = filebase64("jar/prov.jar")
  }
}

