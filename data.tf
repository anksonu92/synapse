data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "module" {
  name = var.resource_group_name
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}
