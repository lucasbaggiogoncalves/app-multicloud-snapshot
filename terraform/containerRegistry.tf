resource "azurerm_container_registry" "torre-cloud" {
  name                = "app-snapshot-cloud-app"
  resource_group_name = azurerm_resource_group.torre-cloud.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = var.tags
}