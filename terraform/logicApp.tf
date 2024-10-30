resource "azurerm_logic_app_workflow" "app-snapshot" {
  name                = var.projects.gerador-snapshot
  location            = var.location
  resource_group_name = azurerm_resource_group.torre-cloud.name
  tags                = var.tags

  lifecycle {
    ignore_changes = [parameters, workflow_parameters]
  }
}

resource "azurerm_logic_app_trigger_http_request" "app-snapshot" {
  name         = "${var.projects.gerador-snapshot}-http-trigger"
  logic_app_id = azurerm_logic_app_workflow.app-snapshot.id

  schema = <<SCHEMA
{
  "type": "object",
  "properties": {
      "customer": {
          "type": "string"
      },
      "cloud": {
          "type": "string"
      },
      "awsregion": {
          "type": "string"
      },
      "ociregion": {
          "type": "string"
      },
      "machines": {
          "type": "string"
      },
      "disk": {
          "type": "string"
      },
      "email": {
          "type": "string"
      }
  }
}
SCHEMA
}

// Dev

resource "azurerm_logic_app_workflow" "app-snapshot-dev" {
  name                = "${var.projects.gerador-snapshot}-dev"
  location            = var.location
  resource_group_name = azurerm_resource_group.torre-cloud.name
  tags                = var.tags-dev

  lifecycle {
    ignore_changes = [parameters, workflow_parameters]
  }
}

resource "azurerm_logic_app_trigger_http_request" "app-snapshot-dev" {
  name         = "${var.projects.gerador-snapshot}-http-trigger"
  logic_app_id = azurerm_logic_app_workflow.app-snapshot-dev.id

  schema = <<SCHEMA
{
  "type": "object",
  "properties": {
      "customer": {
          "type": "string"
      },
      "cloud": {
          "type": "string"
      },
      "awsregion": {
          "type": "string"
      },
      "ociregion": {
          "type": "string"
      },
      "machines": {
          "type": "string"
      },
      "disk": {
          "type": "string"
      },
      "email": {
          "type": "string"
      }
  }
}
SCHEMA
}
