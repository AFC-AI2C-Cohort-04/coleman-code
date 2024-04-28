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

## get python, pip, venv, and activate
``` bash
sudo apt-get update && sudo apt-get upgrade -y && \
sudo apt-get install python3 python3-pip python3-venv -y && \
python3 -m venv .venv && \
source myenv/bin/activate
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

## get necessary updates and installs
``` bash
# docker
sudo apt-get update && sudo apt-get install -y ca-certificates curl jq python3-pip python3-venv gnupg software-properties-common uuid && \
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && \
# sudo groupadd docker # not usually needed
sudo usermod -aG docker $USER
newgrp docker
su - $USER
# docker --version # run to verify

# azure cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login --use-device-code

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
helm repo add bitnami https://charts.bitnami.com/bitnami && \
helm repo update && \
helm install my-nginx bitnami/nginx-ingress-controller --version v9.3.24
```

## set-up acr
``` bash
acr_name=acr$(uuid | cut -c1-8) && \
rg_name=project6 && \

az group create \
  --name $rg_name \
  --location eastus && \
az acr create \
  --resource-group $rg_name \
  --name $acr_name \
  --sku Basic && \

az acr update \
  --name $acr_name \
  --admin-enabled true && \
az acr login \
  --name $acr_name
```

## create aks cluter
``` bash
aks_name=project6cluster && \

az aks create \
  --resource-group $rg_name \
  --name $aks_name \
  --enable-managed-identity \
  --node-count 2 \
  --generate-ssh-keys && \

az aks update \
  --name $aks_name \
  --resource-group $rg_name \
  --attach-acr $acr_name && \
az aks get-credentials \
  --resource-group $rg_name \
  --name $aks_name && \
kubectl get nodes
```
