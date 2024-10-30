localPath="./oci/auth-clientes/*"
containerPath="container-path"
sasToken="sas-token"

azcopy copy $localPath ${containerPath}${sasToken} --recursive