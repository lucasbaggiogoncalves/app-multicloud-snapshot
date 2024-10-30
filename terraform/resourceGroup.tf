resource "azurerm_resource_group" "torre-cloud" {
  name     = "torre-cloud-interno-prd"
  location = var.location
  tags     = var.tags
}
