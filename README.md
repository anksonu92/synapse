<!-- BEGIN_TF_DOCS -->
# Terraform AzureRM Lens Synapse

- [Purpose](#purpose)
- [Details](#details)
- [Usage](#usage)
- [Gotchas](#gotchas)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Contributing](#contributing)

## Purpose

Creates an Azure Synapse Workspace with:
- Dedicated Spark Pool
- Dedicated SQL Pool
- Linked Services:
    - Azure Datalake (from Lens Base)
    - Azure SQL Pool
    - Azure Key Vault (from Lens Base)

## Details
- Synapse Workspace is accessible by Azure and the IP of the principal where the workspace was deployed based on default workspace firewall rules
- Stores connection strings to SQL Pool in Azure Key Vault, including
    - SQL
    - Serverless
    - JDBC
    - ODBC
- Workspace managed identity is given "Key Vault Secrets User" access to Key Vault for access to read secrets via linked service

## Usage

This module may be used via a module call specifying the following input variables.

```
provider "azurerm" {
  storage_use_azuread = true
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
    name         = "ls_key_vault"
    uri = module.lens_base.key_vault.vault_uri
  }

  depends_on = [
    module.lens_base
  ]

}
```

## Gotchas

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_datalake_container_id"></a> [datalake\_container\_id](#input\_datalake\_container\_id) | The ID of the Storage Account Datalake Container used for Workspace datalake storage | `string` | n/a | yes |
| <a name="input_datalake_id"></a> [datalake\_id](#input\_datalake\_id) | The ID of the Storage Account Datalake used for all Workspace datalake storage | `string` | n/a | yes |
| <a name="input_datalake_linked_service"></a> [datalake\_linked\_service](#input\_datalake\_linked\_service) | An Object representing the Datalake used as a Workspace Linked Service. | <pre>object({<br>    name         = string<br>    dfs_endpoint = string<br>  })</pre> | n/a | yes |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | The ID of the Key Vault used for all secrets/keys and encryption operations. | `string` | n/a | yes |
| <a name="input_key_vault_linked_service"></a> [key\_vault\_linked\_service](#input\_key\_vault\_linked\_service) | An Object representing the Key Vault used for Synapse Workspace Linked Service. | <pre>object({<br>    name = string<br>    uri  = string<br>  })</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where modules resources will be deployed. The resource group location will be used for all resources in this module as well. | `string` | n/a | yes |
| <a name="input_admin_name"></a> [admin\_name](#input\_admin\_name) | Name of the Azure Synapse Analytics workspace Administrator | `string` | `"synapseAdminUser"` | no |
| <a name="input_enable_private_networking"></a> [enable\_private\_networking](#input\_enable\_private\_networking) | If enabled, private networking will disable internet access to all resources contained within the module. This change requires either an exception list of allowed IPs (including build agents where Terraform is executed!) or that the burden of connectivity amongst all pieces of the infrastructure has been addressed. Defaults to 'false' for the aforementioned reasons. Only set to 'true' if you understand these caveats. | `bool` | `false` | no |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | A map of objects representing firewall rules to configure on the synapse workspace. Set start ip to '0.0.0.0' and end ip to '255.255.255.255' to allow access from the entire internet. *Note* this is NOT ADVISED IN PRODUCTION ENVIRONMENTS | <pre>map(object({<br>    start_ip_address = string<br>    end_ip_address   = string<br>  }))</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Azure Synapse Analytics workspace | `string` | `"lens-synapse"` | no |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | A map of objects representing the role and object id assignments. Valid role names are 'Workspace Admin', 'Apache Spark Admin', or 'Sql Admin'. | <pre>map(object({<br>    object_id = string<br>    role_name = string<br>  }))</pre> | `{}` | no |
| <a name="input_spark_pool"></a> [spark\_pool](#input\_spark\_pool) | An object containing the Synapse Spark Pool config. | <pre>object({<br>    name             = string,<br>    node_size_family = string,<br>    node_size        = string<br>  })</pre> | <pre>{<br>  "name": "dataEngineering",<br>  "node_size": "Small",<br>  "node_size_family": "MemoryOptimized"<br>}</pre> | no |
| <a name="input_sql_pool"></a> [sql\_pool](#input\_sql\_pool) | An object containing the Synapse SQL Pool config. | <pre>object({<br>    name     = string,<br>    sku_name = string<br>  })</pre> | <pre>{<br>  "name": "mdw",<br>  "sku_name": "DW100c"<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to set for all resources | `map(string)` | <pre>{<br>  "Application": "analytics",<br>  "Department": "it",<br>  "Team": "analytics"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_synapse"></a> [synapse](#output\_synapse) | Azure Synapse Workspace Config |

## Contributing
### Pre-Commit Hooks

Git hook scripts are useful for identifying simple issues before submission to code review. We run our hooks on every commit to automatically point out issues in the Terraform code such as missing parentheses, and to enforce consistent Terraform styling and spacing. By pointing these issues out before code review, this allows a code reviewer to focus on the architecture of a change while not wasting time with trivial style nitpicks.

#### Pre-Commit Installation

Before you can run hooks, you need to have the pre-commit package manager installed.

Using pip:

```
pip install pre-commit
```

Non-administrative installation:

to upgrade: run again, to uninstall: pass uninstall to python
does not work on platforms without symlink support (windows)

```
curl https://pre-commit.com/install-local.py | python -
```

Afterward, `pre-commit --version` should show you what version you're using.

#### Pre-Commit Configuration

The pre-commit config for this repo may be found in `.pre-commit-config.yaml`, the contents of which takes the following form:

Run `pre-commit install` to set up the git hook scripts:

```
$ pre-commit install
pre-commit installed at .git/hooks/pre-commit
```

Now pre-commit will run automatically on git commit
<!-- END_TF_DOCS -->


#### _this README is auto-generated by [terraform-docs](https://terraform-docs.io)_