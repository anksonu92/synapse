terraform {
  required_version = "~> 1.1"
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "~> 3.9"
    }
    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "~> 3.0"
    }
    time = {
      source  = "registry.terraform.io/hashicorp/time"
      version = "~> 0.7"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = false
  storage_use_azuread        = true # prereq to using 'rbac' access model!
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  location = "eastus2"
  name     = "lens-synapse-test-basic"
}

module "lens_base" {
  source = "git::https://dev.azure.com/di-data/Lens/_git/terraform-azurerm-lens-base?ref=v1.3.0"

  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  depends_on = [
    azurerm_resource_group.test
  ]
}

module "lens_synapse" {
  source = "../.."

  resource_group_name = azurerm_resource_group.test.name

  key_vault_id          = module.lens_base.key_vault.id
  datalake_id           = module.lens_base.datalake.id
  datalake_container_id = module.lens_base.datalake.containers["mdw"].id

  datalake_linked_service = {
    name         = "ls_adls"
    dfs_endpoint = module.lens_base.datalake.primary_dfs_endpoint
  }

  key_vault_linked_service = {
    name = "ls_key_vault"
    uri  = module.lens_base.key_vault.vault_uri
  }

  depends_on = [
    module.lens_base
  ]

}

output "key_vault" {
  value = module.lens_base.key_vault
}

output "datalake" {
  value = module.lens_base.datalake
}

output "synapse" {
  value = module.lens_synapse.synapse
}
