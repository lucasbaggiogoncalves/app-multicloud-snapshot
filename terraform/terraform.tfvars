customer = {
  "tenantid"       = "tenantid"
  "subscriptionid" = "subid"
}

enviroment = "prd"

projects = {
  "torre-cloud"      = "interno-torre-cloud"
  "gerador-snapshot" = "app-snapshot"
}

location = "eastus2"

tags = {
  "created-by"  = "Lucas Baggio"
  "environment" = "prd"
}

tags-dev = {
  "created-by"  = "Lucas Baggio"
  "environment" = "dev"
}

app-snapshot-aut-acc-runbooks = {
  "azure-snapshot" = "../app-snapshot/azure/aut-account/azure-snapshot.ps1"
  "aws-snapshot"   = "../app-snapshot/azure/aut-account/aws-snapshot.ps1"
}

app-snapshot-aut-acc-runbooks-py = {
  "oci-snapshot" = "../app-snapshot/azure/aut-account/oci-snapshot.py"
}

app-snapshot-aut-acc-connections = {
  "empresa1" = {
    "TenantId"      = "tenantid"
    "ApplicationId" = "appid"
    "Secret"        = "secret",
  }
  "empresa2" = {
    "TenantId"      = "tenantid"
    "ApplicationId" = "appid"
    "Secret"        = "secret",
  }
  "empresa3" = {
    "TenantId"      = "tenantid"
    "ApplicationId" = "appid"
    "Secret"        = "secret",
  }
}

app-snapshot-aut-acc-credentials = {
  "empresa1" = {
    "username"    = "username"
    "password"    = "password"
    "description" = "Credencial para autenticação na AWS"
  }
  "empresa2" = {
    "username"    = "username"
    "password"    = "password"
    "description" = "Credencial para autenticação na AWS"
  }
}

app-snapshot-stg-acc-oci-auth = "../app-snapshot/oci/auth-clientes/*"

app-snapshot-stg-acc-oci-auth-sas = "storageaccsas"