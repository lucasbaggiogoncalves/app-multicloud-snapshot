resource "azurerm_log_analytics_workspace" "torre-cloud" {
  name                = "apps-torre-cloud"
  location            = var.location
  resource_group_name = azurerm_resource_group.torre-cloud.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}