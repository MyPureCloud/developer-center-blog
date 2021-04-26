terraform {
  required_version = "~> 0.14.0"
  required_providers {
    genesyscloud = {
      source  = "mypurecloud/genesyscloud"
      
    }
  }
}

provider "genesyscloud"{}

resource "genesyscloud_tf_export" "export" {
  directory          = "./genesyscloud"
  resource_types     = ["genesyscloud_user"]
  include_state_file = true
}




