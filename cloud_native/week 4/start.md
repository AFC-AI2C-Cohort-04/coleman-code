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

0b.   get handout
``` bash
cd ~ && \
wget https://cloudnativehandout.blob.core.windows.net/project2/studentvmcreator.tar.gz && \
tar -xvzf studentvmcreator.tar.gz
```

0c.   ___
``` bash

```
