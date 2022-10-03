resource "azurerm_synapse_linked_service" "datalake" {
  name                 = var.datalake_linked_service.name
  synapse_workspace_id = azurerm_synapse_workspace.lens.id
  type                 = "AzureBlobFS"

  depends_on = [
    time_sleep.await_synapse_firewall_rule_propagation,
    time_sleep.await_datalake_rbac_propagation
  ]

  type_properties_json = <<JSON
{
  "url": "${var.datalake_linked_service.dfs_endpoint}"
}
JSON
}

resource "azurerm_synapse_linked_service" "key_vault" {
  name                 = var.key_vault_linked_service.name
  synapse_workspace_id = azurerm_synapse_workspace.lens.id
  description          = "Linked service for the Key Vault used for storing secrets, password, connection strings, etc."
  type                 = "AzureKeyVault"

  depends_on = [
    time_sleep.await_synapse_firewall_rule_propagation,
    time_sleep.await_key_vault_rbac_propagation
  ]

  type_properties_json = <<JSON
{
  "baseUrl": "${var.key_vault_linked_service.uri}"
}
JSON

}

resource "azurerm_synapse_linked_service" "az_sql_mi" {
  name                 = "ls_asql_sqlauth"
  synapse_workspace_id = azurerm_synapse_workspace.lens.id
  description          = "Linked service for the Azure SQL metadata database that uses the ADF Managed Identity as authentication"
  type                 = "AzureSqlDatabase"

  parameters = {
    databaseServerName = azurerm_synapse_workspace.lens.connectivity_endpoints.sql
    databaseName       = azurerm_synapse_sql_pool.lens.name
    databaseUserName   = azurerm_synapse_workspace.lens.sql_administrator_login
    connectionSecret   = azurerm_key_vault_secret.synapse_admin_user_password.name
  }

  depends_on = [
    azurerm_synapse_linked_service.key_vault
  ]

  type_properties_json = <<JSON
{
  "connectionString": "Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source=@{linkedService().databaseServerName};Initial Catalog=@{linkedService().databaseName};User ID=@{linkedService().databaseUserName}",
    "password": {
       "type": "AzureKeyVaultSecret",
       "store": {
          "referenceName": "${azurerm_synapse_linked_service.key_vault.name}",
          "type": "LinkedServiceReference"
       },
        "secretName": {
           "value": "@linkedService().connectionSecret",
           "type": "Expression"
         }
    }
}
JSON
}

resource "azurerm_synapse_linked_service" "az_sql" {
  name                 = "ls_asql_mi"
  synapse_workspace_id = azurerm_synapse_workspace.lens.id
  description          = "Linked service for the Azure SQL metadata database that uses the ADF Managed Identity as authentication"
  type                 = "AzureSqlDatabase"

  parameters = {
    connectionString = "sec-mdw-db-connection-string"
  }

  depends_on = [
    azurerm_synapse_linked_service.key_vault
  ]

  type_properties_json = <<JSON
{
  "connectionString": {
    "type": "AzureKeyVaultSecret",
    "store": {
       "referenceName": "${azurerm_synapse_linked_service.key_vault.name}",
       "type": "LinkedServiceReference"
        },
        "secretName": {
          "value": "@linkedService().connectionString",
          "type": "Expression"
        }
  }
}
JSON

}
