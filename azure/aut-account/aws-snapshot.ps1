# Parameters
param(
    [Parameter(Mandatory = $true)][object] $variables
)

# Inicializa variáveis
$customer = $variables.customer
$instanceIds = $variables.machines -split ','
$diskType = $variables.disk
$region = $variables.awsregion

# Inicializa credenciais
$awsCredential = Get-AutomationPSCredential -Name "aws-${customer}"
$awsAccessKey = $awsCredential.UserName
$awsSecretKey = $awsCredential.GetNetworkCredential().Password

Import-Module AWSPowerShell

# Autentica AWS
try {                
    Set-AwsCredentials -AccessKey $awsAccessKey -SecretKey $awsSecretKey -StoreAs AWSProfile
    Set-AWSCredential -ProfileName AWSProfile
    Write-Output "Autenticado AWS do cliente $customer"
}
catch {
    throw "Falha na autenticação AWS do cliente ${customer}.`n$($_.Exception)"
}

# Cria Snapshot
foreach ($instanceId in $instanceIds) {
    $instance = Get-EC2Instance -InstanceId $instanceId -Region $region

    if ($diskType -eq "disk-os" -or $diskType -eq "disk-both") {
        foreach ($volume in $instance.Instances[0].BlockDeviceMappings) {
            if($volume.DeviceName -eq '/dev/xvda' -or $volume.DeviceName -eq '/dev/sda1') {
                $snapshot = New-EC2Snapshot -Region $region -VolumeId $volume.Ebs.VolumeId -Description "Snapshot do volume: $($volume.Ebs.VolumeId), da instancia: $($instance.Instances[0].InstanceId). EmpresaX"
    
                if ($snapshot) {
                    Write-Output "Snapshot criado para volume root: $($volume.Ebs.VolumeId) da instancia: $($instance.Instances[0].InstanceId) / Snapshot ID: $($snapshot.SnapshotId)"
                } else {
                    Write-Output "Erro ao criar snapshot para volume root: $($volume.Ebs.VolumeId) da instancia: $($instance.Instances[0].InstanceId)"
                }
            }
        }
    }

    if ($diskType -eq "disk-data" -or $diskType -eq "disk-both") {
        foreach ($volume in $instance.Instances[0].BlockDeviceMappings) {
            if($volume.DeviceName -ne '/dev/xvda' -and $volume.DeviceName -ne '/dev/sda1') {
                $snapshot = New-EC2Snapshot -Region $region -VolumeId $volume.Ebs.VolumeId -Description "Snapshot do volume: $($volume.Ebs.VolumeId), da instancia: $($instance.Instances[0].InstanceId). EmpresaX"
    
                if ($snapshot) {
                    Write-Output "Snapshot criado para volume de dados: $($volume.Ebs.VolumeId) da instancia: $($instance.Instances[0].InstanceId) / Snapshot ID: $($snapshot.SnapshotId)"
                } else {
                    Write-Output "Erro ao criar snapshot para volume de dados: $($volume.Ebs.VolumeId) da instancia: $($instance.Instances[0].InstanceId)"
                }
            }
        }
    }
}