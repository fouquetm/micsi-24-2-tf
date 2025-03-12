data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_resource_group" "hub" {
  name = var.hub_resource_group_name
}