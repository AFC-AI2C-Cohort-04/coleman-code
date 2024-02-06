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

0b.   make directory, and create virtual environment
``` bash
cd ~
sudo apt-get update
mkdir my_flask_api
```

0c.   ...
```
cd my_flask_api

# --------------------------------------

sudo groupadd docker # should already exist
sudo usermod -aG docker $USER
newgrp docker
su - $USER # re-enter password
mkdir ~/docker_test && cd ~/docker_test
docker run hello-world
```

---
