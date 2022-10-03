resource "azurerm_role_assignment" "synapse_key_vault_rbac" {
  scope                = var.key_vault_id
  principal_id         = azurerm_synapse_workspace.lens.identity[0].principal_id
  role_definition_name = "Key Vault Secrets User"
}

resource "time_sleep" "await_key_vault_rbac_propagation" {
  depends_on = [
    azurerm_role_assignment.synapse_key_vault_rbac
  ]

  create_duration = "2m"
}

resource "azurerm_key_vault_secret" "synapse_admin_user" {
  key_vault_id = var.key_vault_id
  name         = "sec-synapse-admin-user"
  value        = azurerm_synapse_workspace.lens.sql_administrator_login
}

resource "azurerm_key_vault_secret" "synapse_admin_user_password" {
  key_vault_id = var.key_vault_id
  name         = "sec-synapse-admin-pwd"
  value        = azurerm_synapse_workspace.lens.sql_administrator_login_password
}

resource "azurerm_key_vault_secret" "synapse_connection_string" {
  key_vault_id = var.key_vault_id
  name         = "sec-synapse-sql-connection-string"
  value        = "Server=tcp:${azurerm_synapse_workspace.lens.connectivity_endpoints.sql},1433;Initial Catalog=${azurerm_synapse_sql_pool.lens.name};Persist Security Info=False;User ID=${azurerm_synapse_workspace.lens.sql_administrator_login};Password=${azurerm_synapse_workspace.lens.sql_administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}

resource "azurerm_key_vault_secret" "synapse_serverless_connection_string" {
  key_vault_id = var.key_vault_id
  name         = "sec-synapse-serverless-connection-string"
  value        = "Server=tcp:${azurerm_synapse_workspace.lens.connectivity_endpoints.sql},1433;User ID=${azurerm_synapse_workspace.lens.sql_administrator_login};Password=${azurerm_synapse_workspace.lens.sql_administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
}

resource "azurerm_key_vault_secret" "synapse_connection_string_jdbc" {
  key_vault_id = var.key_vault_id
  name         = "sec-synapse-sql-jdbc-connection-string"
  value        = "jdbc:sqlserver://${azurerm_synapse_workspace.lens.connectivity_endpoints.sqlOnDemand}:1433;databasename=${azurerm_synapse_sql_pool.lens.name};user=${azurerm_synapse_workspace.lens.sql_administrator_login};password=${azurerm_synapse_workspace.lens.sql_administrator_login_password};driver=com.microsoft.sqlserver.jdbc.SQLServerDriver"
}

resource "azurerm_key_vault_secret" "synapse_connection_stringo_odbc" {
  key_vault_id = var.key_vault_id
  name         = "sec-synapse-sql-odbc-connection-string"
  value        = "DRIVER={ODBC Driver 17 for SQL Server};SERVER=${azurerm_synapse_workspace.lens.connectivity_endpoints.sql};DATABASE=${azurerm_synapse_sql_pool.lens.name};UID=${azurerm_synapse_workspace.lens.sql_administrator_login};PWD=${azurerm_synapse_workspace.lens.sql_administrator_login_password}"
}
