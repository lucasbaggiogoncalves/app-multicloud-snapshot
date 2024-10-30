const form = document.getElementById('form');
const awsRegionSelect = document.getElementById('aws-region');
const ociRegionSelect = document.getElementById('oci-region');
const machinesSelect = document.getElementById('machine');
const containerValidation = document.getElementById('container-validation');
const containerReturn = document.getElementById('container-return');
const containerButtonRefresh = document.getElementById('container-button-refresh');

machinesSelect.style.display = "none";
awsRegionSelect.style.display = "none";
ociRegionSelect.style.display = "none";
containerValidation.style.display = "none";
containerReturn.style.display = "none";
containerButtonRefresh.style.display = "none";

document.addEventListener("DOMContentLoaded", function () {
    const customerSelect = document.getElementById('customer');
    const cloudSelect = document.getElementById('cloud');
    const azureOption = document.querySelector('#cloud option[value="azure"]');
    const awsOption = document.querySelector('#cloud option[value="aws"]');
    const ociOption = document.querySelector('#cloud option[value="oci"]');

    const returnMessageValidation = document.getElementById('message-validation');

    let isCustomerSelected = false;

    customerSelect.addEventListener('change', () => {
        cloudSelect.value = "";

        switch (customerSelect.value) {
            case 'empresa1':
                azureOption.disabled = true;
                awsOption.disabled = false;
                ociOption.disabled = true;
                break;
            case 'empresa2':
            case 'empresa3':
                azureOption.disabled = true;
                awsOption.disabled = true;
                ociOption.disabled = false;
                break;
            case 'empresa4':
                azureOption.disabled = false;
                awsOption.disabled = true;
                ociOption.disabled = false;
                break;
            case 'empresa6':
                azureOption.disabled = false;
                awsOption.disabled = true;
                ociOption.disabled = true;
                break;
            case 'empresa7':
                azureOption.disabled = false;
                awsOption.disabled = false;
                ociOption.disabled = true;
                break;
            case 'empresa8':
                azureOption.disabled = false;
                awsOption.disabled = false;
                ociOption.disabled = false;
                break;
        }
        isCustomerSelected = true;
    })

    cloudSelect.addEventListener('change', () => {
        if (!isCustomerSelected) return;

        let isCloudSupported = false;

        // Azure
        if (cloudSelect.value === 'azure') {
            awsRegionSelect.style.display = "none";
            ociRegionSelect.style.display = "none";
            machinesSelect.style.display = "block";
            document.getElementById('machine').placeholder = "Máquina(s) separado por vírgula / ex: vm1,vm2";
            if (customerSelect.value === 'empresa4'
                || customerSelect.value === 'empresa7'
                || customerSelect.value === 'empresa8') {
                isCloudSupported = true;
            }
        }
        // AWS
        if (cloudSelect.value === 'aws') {
            ociRegionSelect.style.display = "none";
            awsRegionSelect.style.display = "block";
            machinesSelect.style.display = "block";
            document.getElementById('machine').placeholder = "ID(s) da(s) instância(s) separado por vírgula / ex: id1,id2";
            if (customerSelect.value === 'empresa8'
                || customerSelect.value === 'empresa1') {
                isCloudSupported = true;
            }
        }
        // OCI
        if (cloudSelect.value === 'oci') {
            awsRegionSelect.style.display = "none";
            ociRegionSelect.style.display = "block";
            machinesSelect.style.display = "block";
            document.getElementById('machine').placeholder = "Nome(s) da(s) instância(s) separado por vírgula / ex: vm1,vm2";
            if (customerSelect.value === 'empresa4'
                || customerSelect.value === 'empresa8'
                || customerSelect.value === 'empresa3'
                || customerSelect.value === 'empresa2') {
                isCloudSupported = true;
            }
        }
        if (isCloudSupported) {
            containerValidation.style.display = "block";
            returnMessageValidation.innerHTML = `Cliente  ${customerSelect.value.toUpperCase()} e cloud ${cloudSelect.value.toUpperCase()} suportado 🟢`;
        } else {
            containerValidation.style.display = "block";
            containerButtonRefresh.style.display = "flex";
            form.style.display = "none";
            returnMessageValidation.innerHTML = `Cliente ${customerSelect.value.toUpperCase()} e cloud ${cloudSelect.value.toUpperCase()} não suportado ❌`;
        }
    })
});

form.addEventListener('submit', async (event) => {
    event.preventDefault();

    const customerSelect = document.getElementById('customer').value;
    const cloudSelect = document.getElementById('cloud').value;
    const awsRegionSelect = document.getElementById('aws-region').value;
    const ociRegionSelect = document.getElementById('oci-region').value;
    const machinesSelect = document.getElementById('machine').value;
    const diskSelect = document.querySelector('input[name="radio"]:checked').value;
    const email = document.getElementById('email').value;

    let data = {
        "customer": customerSelect,
        "cloud": cloudSelect,
        "awsregion": awsRegionSelect,
        "ociregion": ociRegionSelect,
        "machines": machinesSelect,
        "disk": diskSelect,
        "email": email
    };

    let jsonData = JSON.stringify(data);
    const logicAppUrl = "logic-app-url";
    const returnMessageSuccess = document.getElementById('return-message-success');

    let response = await fetch(logicAppUrl, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: jsonData
    })

    if (response.ok) {
        returnMessageSuccess.innerHTML = "Criação acionada, verificar em minutos logs por e-mail 🟢";
        containerButtonRefresh.style.display = "flex";
        containerReturn.style.display = "block";
        containerValidation.style.display = "none";
        form.style.display = "none";
    } else {
        returnMessageSuccess.innerHTML = "Erro ao acionar criação, falar com equipe de cloud ❌";
        containerButtonRefresh.style.display = "flex";
        containerReturn.style.display = "block";
        containerValidation.style.display = "none";
        form.style.display = "none";
    }
    form.reset();
})

// service