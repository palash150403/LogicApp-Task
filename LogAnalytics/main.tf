data "azurerm_resource_group" "rg" {
  name = var.rg_name
}


resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_workspace_retention_days
}