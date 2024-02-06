## Flask Tutorial

0a.   create vm and login with password
``` bash
az group create --name flask_rg --location eastus && \
az vm create \
  --resource-group flask_rg \
  --name flask_vm \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username azureuser \
  --admin-password <PASSWORD> && \
PUBLIC_IP=$(az vm show -d -g flask_rg -n flask_vm --query publicIps -o tsv) && \
ssh azureuser@$PUBLIC_IP
```

0b.   make directory, and create python virtual environment
``` bash
cd ~ && \
sudo apt-get update && \
apt install python3.10-venv && \
mkdir my_flask_api && \
cd my_flask_api && \
python3 -m venv env && \
source venv/bin/activate
```

0c.   ...
```

```

---
