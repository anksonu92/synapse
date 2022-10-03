output "synapse" {
  description = "Azure Synapse Workspace Config"
  value = {
    workspace = {
      id                          = azurerm_synapse_workspace.lens.id
      connectivity_endpoints      = azurerm_synapse_workspace.lens.connectivity_endpoints
      principal_id                = azurerm_synapse_workspace.lens.identity[0].principal_id
      managed_resource_group_name = azurerm_synapse_workspace.lens.managed_resource_group_name
    }
    sql_pool = {
      id = azurerm_synapse_sql_pool.lens.id
    }
    spark_pool = {
      id = azurerm_synapse_spark_pool.lens.id
    }
  }
}
