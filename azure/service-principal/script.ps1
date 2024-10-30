############################################################
# Rodar no Cloud Shell, por limitaçÕes do Connect-AzureAD #
###########################################################

# Preencher variáveis
$servicePrincipalName = "EmpresaX - App-CreateSnapshot"
$roleDefinitionName = "EmpresaX - CreateSnapshot - Role"
$roleDescription = "Permissões para aplicação de geração de snapshots da EmpresaX"

$subscriptionsIds = (Get-AzSubscription).Id

# Cria o SP, remove as credenciais e recria
Connect-AzureAD
$servicePrincipal = New-AzADServicePrincipal -DisplayName $servicePrincipalName
$servicePrincipalAppId = (Get-AzureADApplication -SearchString $servicePrincipal.DisplayName).AppId
$servicePrincipalObjectId = (Get-AzureADApplication -SearchString $servicePrincipal.DisplayName).ObjectId
$servicePrincipalKeyId = (Get-AzureADApplicationPasswordCredential -ObjectId $servicePrincipalObjectId).KeyId
Remove-AzureADApplicationPasswordCredential -ObjectId $servicePrincipalObjectId -KeyId $servicePrincipalKeyId
New-AzureADApplicationPasswordCredential -ObjectId $servicePrincipalObjectId -StartDate (Get-Date) -EndDate (Get-Date).AddYears(10)

Write-Output "AppId: ${servicePrincipalAppId}"

# Permissões custom
$assignableScopes = $subscriptionsIds | ForEach-Object { "/subscriptions/$_" }

$role = New-Object -TypeName Microsoft.Azure.Commands.Resources.Models.Authorization.PSRoleDefinition 
$role.Name = $roleDefinitionName
$role.Description = $roleDescription
$role.IsCustom = $true
$role.AssignableScopes = $assignableScopes
$role.Actions = @(
    "Microsoft.Compute/disks/read",
    "Microsoft.Compute/snapshots/write",
    "Microsoft.Compute/virtualMachines/read",
    "Microsoft.Compute/disks/beginGetAccess/action",
    "Microsoft.Compute/snapshots/read"
)
New-AzRoleDefinition -Role $role

# Vincula Role ao SP
foreach ($assignableScope in $assignableScopes) {
    az role assignment create `
        --assignee $servicePrincipalAppId `
        --role $roleDefinitionName `
        --scope $assignableScope
}