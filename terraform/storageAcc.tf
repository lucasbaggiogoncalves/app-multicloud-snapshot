resource "azurerm_storage_account" "torre-cloud" {
  name                     = "torrecloudstg"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.torre-cloud.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  tags                     = var.tags
}

resource "azurerm_storage_container" "app-snapshot-oci-auth" {
  name                  = "oci"
  storage_account_name  = azurerm_storage_account.torre-cloud.name
  container_access_type = "private"
}