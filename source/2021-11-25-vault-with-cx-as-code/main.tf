terraform {
    required_version = ">= 0.12"
    required_providers {
        genesyscloud = {
            source  = "mypurecloud/genesyscloud"
            version = "0.14.0"
        }
    }
}

provider "vault" {
    # address attribute defaults to $VAULT_ADDR
}

provider "genesyscloud" {
    oauthclient_id     = data.vault_generic_secret.genesys_client_credentials.data["client_id"]
    oauthclient_secret = data.vault_generic_secret.genesys_client_credentials.data["client_secret"]
    aws_region         = data.vault_generic_secret.genesys_client_credentials.data["region"]
}

resource "genesyscloud_routing_wrapupcode" "example" {
    name = "Test WUC"
}

data "vault_generic_secret" "genesys_client_credentials" {
    path = "secret/genesyscloud_creds"
}