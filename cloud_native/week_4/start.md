## Cloud Native | Week 4 | Start

0a.   create temporary resource for handout
``` bash
PASSWORD=<PASSWORD> && \
az group create --name temp_rg --location eastus && \
az vm create \
  --resource-group temp_rg \
  --name temp_vm \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username azureuser \
  --admin-password $PASSWORD && \
PUBLIC_IP=$(az vm show -d -g temp_rg -n temp_vm --query publicIps -o tsv) && \
ssh azureuser@$PUBLIC_IP
```

0b.   get handout and packer
``` bash
cd ~ && \
wget https://cloudnativehandout.blob.core.windows.net/project2/studentvmcreator.tar.gz && \
tar -xvzf studentvmcreator.tar.gz && \
sudo apt update && \
sudo apt install packer
```

0c.   login to azure cli, create azure rbac and use packer to build vm image file
``` bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && \
az login --use-device && \
subscription_id=$(az account list --query "[?isDefault].id" --output tsv) && \
service_principle=($(az ad sp create-for-rbac --role Contributor --scopes /subscriptions/$subscription_id --query "[appId, password, tenant]" --output tsv)) && \
cd ~/studentvmcreator && \
echo -e "client_id = \"${service_principle[0]}\"
client_secret = \"${service_principle[1]}\"
tenant_id = \"${service_principle[2]}\"
subscription_id = \"$subscription_id\"" > secret.pkrvars.hcl && \
az group create \
  --name studentvm \
  --location eastus && \
packer build \
  -var-file="secret.pkrvars.hcl" \
  -var "resource_group=student_vm" \
  -var "managed_image_name=project2image" .
```

0d.   
``` bash

```
