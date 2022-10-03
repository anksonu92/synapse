resource "random_password" "synapse" {
  length           = 30
  special          = true
  override_special = "_%@#*&^"

  keepers = {
    resource_group_name = var.resource_group_name
  }
}

resource "azurerm_synapse_workspace" "lens" {
  name                                 = format("%s-%s", var.name, random_integer.suffix.result)
  resource_group_name                  = data.azurerm_resource_group.module.name
  location                             = data.azurerm_resource_group.module.location
  storage_data_lake_gen2_filesystem_id = var.datalake_container_id
  sql_administrator_login              = var.admin_name
  sql_administrator_login_password     = random_password.synapse.result

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "synapse_workspace_identity_to_datalake" {
  scope                = var.datalake_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.lens.identity[0].principal_id
}

resource "time_sleep" "await_datalake_rbac_propagation" {
  depends_on = [
    azurerm_role_assignment.synapse_workspace_identity_to_datalake
  ]

  create_duration = "2m"
}

resource "azurerm_synapse_spark_pool" "lens" {
  name                 = var.spark_pool.name
  synapse_workspace_id = azurerm_synapse_workspace.lens.id
  node_size_family     = var.spark_pool.node_size_family
  node_size            = var.spark_pool.node_size

  auto_scale {
    max_node_count = 50
    min_node_count = 3
  }

  auto_pause {
    delay_in_minutes = 15
  }
}

resource "azurerm_synapse_sql_pool" "lens" {
  name                 = var.sql_pool.name
  synapse_workspace_id = azurerm_synapse_workspace.lens.id
  sku_name             = var.sql_pool.sku_name
  create_mode          = "Default"
}

resource "azurerm_synapse_firewall_rule" "lens" {
  for_each = local.synapse_firewall_rules

  name                 = each.key
  synapse_workspace_id = azurerm_synapse_workspace.lens.id
  start_ip_address     = each.value.start_ip_address
  end_ip_address       = each.value.end_ip_address
}

resource "time_sleep" "await_synapse_firewall_rule_propagation" {
  depends_on = [
    azurerm_synapse_firewall_rule.lens
  ]

  create_duration = "30s"
}
