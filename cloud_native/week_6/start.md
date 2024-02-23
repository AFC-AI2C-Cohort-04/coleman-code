## Cloud Native | Week 6 | Start

Start    [Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_1.md)    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_2.md)    [Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_3.md)    [Task 4](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_4.md)

---

0a.   create password, vm, open port 80, and ssh login
``` bash
PASSWORD=<PASSWORD> && \
az group create \
  --location eastus \
  --name studentvm && \
az vm create \
  --location eastus \
  --resource-group studentvm \
  --name project3vm \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --admin-password $PASSWORD && \
az vm open-port \
  --resource-group studentvm \
  --name project2vm \
  --port 80 \
  --priority 1002 && \
PUBLIC_IP=$(az vm show -d -g studentvm -n project3vm --query publicIps -o tsv) && \
ssh azureuser@$PUBLIC_IP
```

0b.   get handout by cloning github repo to vm

---

1a.   get required installs and docker
``` bash
cd ~/ && \
sudo apt-get update && sudo apt-get install -y ca-certificates curl jq python3-pip python3-venv gnupg software-properties-common uuid && \
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && \
# sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
su - $USER
# docker --version
```

1b.   get terraform
``` bash
cd ~/
rm get-docker.sh
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt-get install -y terraform
# terraform --version
```

1c.   get kubectl
``` bash
cd ~/
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# kubectl version --client
```

1d.   get helm
``` bash
cd ~/
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
./get_helm.sh
# helm version
rm get_helm.sh
```

---

2a.   get azure cli
```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && \
az login --use-device
```

2b.   create acr
```
export acr_name=acr00$(uuid | cut -c1-6)
az group create \
  --name project3 \
  --location eastus && \
az acr create \
  --resource-group project3 \
  --name $acr_name \
  --sku Basic
```

2c.   login to acr
```
az acr update \
  --name $acr_name \
  --admin-enabled true && \
az acr login \
  --name $acr_name
```

2d.   create k8s cluster
```
az aks create \
  --resource-group project3 \
  --name project3cluster \
  --enable-managed-identity \
  --node-count 2 \
  --generate-ssh-keys
```

2e.   connect acr to cluster
```
az aks update \
  --resource-group project3 \
  --name project3cluster \
  --attach-acr $acr_name && \
az aks get-credentials \
  --resource-group project2task1 \
  --name project2cluster && \
kubectl get nodes
```

---

[Task 1 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_6/task_1.md)
