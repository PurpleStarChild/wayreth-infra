terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
      version = "2024.6.1"
    }
  }
}

variable "client_id" {
  description = "Grafana oauth client id"
}

provider "authentik" {
  # Configuration options
}

data "authentik_flow" "default-provider-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_scope_mapping" "scope-email" {
  name = "authentik default OAuth Mapping: OpenID 'email'"
}

data "authentik_scope_mapping" "scope-profile" {
  name = "authentik default OAuth Mapping: OpenID 'profile'"
}

data "authentik_scope_mapping" "scope-openid" {
  name = "authentik default OAuth Mapping: OpenID 'openid'"
}

resource "authentik_provider_oauth2" "grafana" {
  name          = "Grafana"
  #  Required. You can use the output of:
  #     $ openssl rand -hex 16
  client_id     = var.client_id

  # Optional: will be generated if not provided
  # client_secret = "my_client_secret"

  authorization_flow  = data.authentik_flow.default-provider-authorization-implicit-consent.id

  redirect_uris = ["https://metrics.housewayreth.org/login/generic_oauth"]

  property_mappings = [
    data.authentik_scope_mapping.scope-email.id,
    data.authentik_scope_mapping.scope-profile.id,
    data.authentik_scope_mapping.scope-openid.id,
  ]
}

resource "authentik_application" "grafana" {
  name              = "Grafana"
  slug              = "grafana"
  protocol_provider = authentik_provider_oauth2.grafana.id
}

resource "authentik_group" "grafana_admins" {
  name    = "Grafana Admins"
}

resource "authentik_group" "grafana_editors" {
  name    = "Grafana Editors"
}

resource "authentik_group" "grafana_viewers" {
  name    = "Grafana Viewers"
}

