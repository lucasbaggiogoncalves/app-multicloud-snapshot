resource "azurerm_container_app_environment" "torre-cloud" {
  name                       = "apps-torre-cloud"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.torre-cloud.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.torre-cloud.id
  tags                       = var.tags
}

resource "azurerm_container_app" "app-snapshot" {
  name                         = "app-snapshot"
  resource_group_name          = azurerm_resource_group.torre-cloud.name
  container_app_environment_id = azurerm_container_app_environment.torre-cloud.id
  revision_mode                = "Single"
  tags                         = var.tags

  secret {
    name  = azurerm_container_registry.torre-cloud.admin_username
    value = azurerm_container_registry.torre-cloud.admin_password
  }

  secret {
    name  = "microsoft-provider-authentication-secret"
    value = "microsoft-secret"
  }

  registry {
    server               = azurerm_container_registry.torre-cloud.login_server
    username             = azurerm_container_registry.torre-cloud.admin_username
    password_secret_name = azurerm_container_registry.torre-cloud.admin_username
  }

  template {
    container {
      name   = "container-app"
      image  = "${azurerm_container_registry.torre-cloud.login_server}/app-snapshot:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
    min_replicas = 1
    max_replicas = 1
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    transport                  = "auto"
    target_port                = 3000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}