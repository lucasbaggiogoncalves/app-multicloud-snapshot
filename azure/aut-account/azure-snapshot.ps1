# Parâmetros
param(
    [Parameter(Mandatory = $true)][object] $variables
)

# Inicializa variáveis
$customer = $variables.customer
$vmNames = $variables.machines -split ','
$diskType = $variables.disk

# Variávies locais automação
$automationResourceGroup = "torre-cloud-interno-prd"
$automationAccountName = "app-snapshot"

# EmpresaX Azure Auth
try {                
    $AzureContext = (Connect-AzAccount -Identity).context
    $AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
    Write-Output "Autenticação EmpresaX efetuada."
}
catch {
    throw "Falha na autenticação EmpresaX.`n$($_.Exception)"
}

# Autenticação Azure Cliente
try {
    $spCredentials = Get-AzAutomationConnection -Name $customer -ResourceGroupName $automationResourceGroup -AutomationAccountName $automationAccountName
    $SecurePassword = ConvertTo-SecureString -String $spCredentials.FieldDefinitionValues.CertificateThumbprint -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $spCredentials.FieldDefinitionValues.ApplicationId, $SecurePassword
    Connect-AzAccount -ServicePrincipal -TenantId $spCredentials.FieldDefinitionValues.TenantId -Credential $Credential
    Write-Output "Autenticado Azure do cliente ${customer}"
}
catch {
    throw "Falha na autenticação Azure do cliente ${customer}.`n$($_.Exception)"
}

# Data e Hora
$brazilTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById("E. South America Standard Time")
$currentDateBrazil = [System.TimeZoneInfo]::ConvertTime((Get-Date), $BrazilTimeZone)
$formattedBrazilTime = Get-Date $currentDateBrazil -Format "dd-MM-yyyy_HH.mm"

# Lista Subscriptions
$subscriptions = Get-AzSubscription

# Criação Snapshots
foreach ($subscription in $subscriptions) {
    Set-AzContext -SubscriptionId $subscription.Id

    foreach ($vmName in $vmNames ) {
        $vms = Get-AzVM -Name $vmName
    }
    
    foreach ($vm in $vms ) {        
        if ($diskType -eq "disk-os" -or $diskType -eq "disk-both") {
            $snapshotNameOS = "snapshot-" + $vm.Name + "-" + "OS-" + $formattedBrazilTime      

            $snapshotConfigOS = New-AzSnapshotConfig -SourceResourceId $vm.StorageProfile.OsDisk.ManagedDisk.Id -CreateOption Copy -Incremental -Location $vm.location -AccountType Standard_LRS
        
            $snapshotResultOS = New-AzSnapshot -ResourceGroupName $vm.ResourceGroupName -SnapshotName $snapshotNameOS -Snapshot $snapshotConfigOS         
            if ($snapshotResultOS) {
                Write-Output "Snapshot criado para disco de sistema da máquina: $($vm.Name) / Nome do snapshot: $snapshotNameOS"
            }
            else {
                Write-Output "Erro ao criar snapshot para disco de sistema da máquina: $($vm.Name)"
            }
        }

        if ($diskType -eq "disk-data" -or $diskType -eq "disk-both") {
            foreach ($disk in $vm.StorageProfile.DataDisks) {
                $snapshotNameData = "snapshot-" + $vm.Name + "-" + "DATA" + "-" + "lun" + $disk.Lun + "-" + $formattedBrazilTime   
                $snapshotConfigData = New-AzSnapshotConfig -SourceResourceId $disk.ManagedDisk.Id -CreateOption Copy -Incremental -Location $vm.location -AccountType Standard_LRS

                $snapshotResultData = New-AzSnapshot -ResourceGroupName $vm.ResourceGroupName -SnapshotName $snapshotNameData -Snapshot $snapshotConfigData
                if ($snapshotResultData) {
                    Write-Output "Snapshot criado para disco de dados LUN: $($disk.Lun) da máquina: $($vm.Name) / Nome do snapshot: $snapshotNameData"
                }
                else {
                    Write-Output "Erro ao criar snapshot para disco de dados LUN: $($disk.Lun) da máquina: $($vm.Name)"
                }
            }
        }
    }
}