resource "azurerm_automation_account" "app-snapshot" {
  name                = var.projects.gerador-snapshot
  location            = var.location
  resource_group_name = azurerm_resource_group.torre-cloud.name
  sku_name            = "Basic"
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_automation_module" "awspowershell" {
  name                    = "AWSPowerShell"
  resource_group_name     = azurerm_resource_group.torre-cloud.name
  automation_account_name = azurerm_automation_account.app-snapshot.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/AWSPowerShell"
  }
}

data "local_file" "app-snapshot-scripts" {
  for_each = var.app-snapshot-aut-acc-runbooks
  filename = each.value
}

resource "azurerm_automation_runbook" "app-snapshot-runbooks" {
  for_each = data.local_file.app-snapshot-scripts

  name                    = each.key
  location                = var.location
  resource_group_name     = azurerm_resource_group.torre-cloud.name
  automation_account_name = azurerm_automation_account.app-snapshot.name
  log_verbose             = false
  log_progress            = true
  description             = "Runbook para efetuar snapshot na ${upper(each.key)}"
  runbook_type            = "PowerShell72"

  content = each.value.content
}

data "local_file" "app-snapshot-scripts-py" {
  for_each = var.app-snapshot-aut-acc-runbooks-py
  filename = each.value
}

resource "azurerm_automation_runbook" "app-snapshot-runbooks-py" {
  for_each = data.local_file.app-snapshot-scripts-py

  name                    = each.key
  location                = var.location
  resource_group_name     = azurerm_resource_group.torre-cloud.name
  automation_account_name = azurerm_automation_account.app-snapshot.name
  log_verbose             = false
  log_progress            = true
  description             = "Runbook para efetuar snapshot na ${upper(each.key)}"
  runbook_type            = "Python3"

  content = each.value.content
}

resource "azurerm_automation_connection" "app-snapshot-connections" {
  for_each = var.app-snapshot-aut-acc-connections

  name                    = each.key
  resource_group_name     = azurerm_resource_group.torre-cloud.name
  automation_account_name = azurerm_automation_account.app-snapshot.name
  type                    = "AzureServicePrincipal"

  values = {
    "ApplicationId" : each.value["ApplicationId"]
    "TenantId" : each.value["TenantId"]
    "SubscriptionId" : each.value["TenantId"]
    "CertificateThumbprint" : each.value["Secret"]
  }
}

resource "azurerm_automation_credential" "app-snapshot-credentials" {
  for_each = var.app-snapshot-aut-acc-credentials

  name                    = each.key
  resource_group_name     = azurerm_resource_group.torre-cloud.name
  automation_account_name = azurerm_automation_account.app-snapshot.name

  username    = each.value["username"]
  password    = each.value["password"]
  description = each.value["description"]
}
