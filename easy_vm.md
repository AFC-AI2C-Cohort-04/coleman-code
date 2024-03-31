## setup rg, vm, and get ip
``` bash
RG_NAME=my_rg && \
VM_NAME=my_vm && \
PASSWORD=<PASSWORD> && \
az group create \
  --location eastus \
  --name $RG_NAME && \
az vm create \
  --location eastus \
  --resource-group $RG_NAME \
  --name $VM_NAME \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --admin-password $PASSWORD && \
PUBLIC_IP=$(az vm show -d -g $RG_NAME -n $VM_NAME --query publicIps -o tsv) && \
echo $PUBLIC_IP
```

---

## git clone
``` bash
sudo apt-get update && sudo apt-get install git && \
GIT_REPO=<REPO_URL> && \
git clone $GIT_REPO
# git clone -b dev/coleman-zachery $GIT_REPO
# ^ use to clone specific branch

# using ssh

# generate ssh
ssh-keygen -t rsa -b 4096 -C "<description>"

# display ssh key, then copy/paste output to github settings > ssh
cat .ssh/id_rsa.pub

# repo > code > code local clone ssh
git clone git@<url>
```

---

## git python and pip
``` bash
sudo apt-get update && sudo apt-get upgrade -y && \
sudo apt-get install python3 python3-pip -y
```

---

## get necessary updates and installs
``` bash
sudo apt-get update && sudo apt-get install -y ca-certificates curl jq python3-pip python3-venv gnupg software-properties-common uuid && \
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && \
# sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
su - $USER
# docker --version
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login --use-device-code
```

## set-up acr
``` bash
acr_name=acr$(uuid | cut -c1-8)
az group create \
  --name acr_rg \
  --location eastus && \
az acr create \
  --resource-group acr_rg \
  --name $acr_name \
  --sku Basic

az acr update \
  --name $acr_name \
  --admin-enabled true && \
az acr login \
  --name $acr_name
```

## create aks cluter
``` bash
az group create \
  --name aks_rg \
  --location eastus && \
aks_name=aks-cloudchat && \
az aks create \
  --resource-group aks_rg \
  --name $aks_name \
  --enable-managed-identity \
  --node-count 2 \
  --generate-ssh-keys

az aks update \
  --name <AKS_NAME> \
  --resource-group <AKS_RG_NAME> \
  --attach-acr <ACR_NAME>
az aks get-credentials \
  --resource-group aks_rg \
  --name $aks_name && \
kubectl get nodes
```
