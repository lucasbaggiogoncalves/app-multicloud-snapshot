from azure.storage.blob import BlobServiceClient
import os
import oci
import sys

# Inicializa variáveis
customer = sys.argv[3]
machines = sys.argv[6].replace(", ", ",").lower()
diskType = sys.argv[4]
region = sys.argv[7]

# Variáveis da storage account
connect_str = "storage-acc-connection-string"
container_name = "oci"
folder_name = "{}-{}".format(customer, region)

# Download das credenciais da OCI
blob_service_client = BlobServiceClient.from_connection_string(connect_str)

blobs_list = blob_service_client.get_container_client(container_name).list_blobs()
for blob in blobs_list:
    if blob.name.startswith(folder_name):

        base_download_folder_path = os.getcwd()

        blob_file_name = blob.name.split('/')[-1]
        download_path = os.path.join(base_download_folder_path, blob_file_name)

        download_blob = blob_service_client.get_blob_client(container_name, blob.name)
        with open(download_path, "wb") as my_blob:
            download_data = download_blob.download_blob().readall()
            my_blob.write(download_data)

# Autenticação OCI do cliente
config = oci.config.from_file("./config")
identity_client = oci.identity.IdentityClient(config)
tenancy_id = config["tenancy"]

# Lista todos os compartimentos
def get_all_compartments(identity_client, root_compartment_id):
    compartments = [identity_client.get_compartment(root_compartment_id).data]
    for compartment in identity_client.list_compartments(root_compartment_id).data:
        compartments.extend(get_all_compartments(identity_client, compartment.id))
    return compartments

# Inicializa variáveis do cliente
compartments = get_all_compartments(identity_client, tenancy_id)
compute_client = oci.core.ComputeClient(config)

block_storage_client = oci.core.BlockstorageClient(config)

# Cria snapshots
for compartment in compartments:

    instances = compute_client.list_instances(compartment_id=compartment.id)

    for instance in instances.data:
        if instance.display_name.lower() in machines.split(","):

            print(f"\tInstancia encontrada com display_name: {instance.display_name}")
            
            if diskType in ['disk-both', 'disk-os']:
                boot_volume_attachment_data = compute_client.list_boot_volume_attachments(
                    availability_domain=instance.availability_domain,
                    compartment_id=compartment.id,
                    instance_id=instance.id).data[0]

                boot_vol_snapshot_create = oci.core.models.CreateBootVolumeBackupDetails(
                    boot_volume_id=boot_volume_attachment_data.boot_volume_id,
                    display_name=f"Snapshot criado para instancia {instance.display_name} para o boot volume. EmpresaX")

                boot_vol_snapshot = block_storage_client.create_boot_volume_backup(
                    boot_vol_snapshot_create)
                if boot_vol_snapshot.data:
                    print(f"Snapshot criado para volume boot: {boot_vol_snapshot.data.boot_volume_id} da instancia: {instance.id} / Snapshot ID: {boot_vol_snapshot.data.id}")
                else:
                    print(f"Erro ao criar snapshot para volume boot: {boot_vol_snapshot.data.boot_volume_id} da instancia: {instance.id}")

            if diskType in ['disk-both', 'disk-data']:
                block_vol_attachments = compute_client.list_volume_attachments(
                    compartment_id=compartment.id,
                    instance_id=instance.id
                ).data

                for attachment in block_vol_attachments:
                    block_vol_snapshot_create = oci.core.models.CreateVolumeBackupDetails(
                        volume_id=attachment.volume_id,
                        display_name=f"Snapshot criado para instancia {instance.display_name} para o volume de dados. EmpresaX")

                    block_vol_snapshot = block_storage_client.create_volume_backup(
                        block_vol_snapshot_create
                    )

                    if block_vol_snapshot.data:
                        print(f"Snapshot criado para volume de dados: {attachment.volume_id} da instancia: {instance.id} / Snapshot ID: {block_vol_snapshot.data.id}")
                    else:
                        print(f"Erro ao criar snapshot para volume de dados: {attachment.volume_id} da instancia: {instance.id}")