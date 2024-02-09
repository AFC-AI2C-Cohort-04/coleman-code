## Cloud Native | Week 4 | Start

Start    [Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_1.md)    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_2.md)    [Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_3.md)    [Task 4](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_4.md)

---

0a.   create password, vm, and then ssh login
``` bash
PASSWORD=<PASSWORD> && \
az group create \
  --location eastus \
  --name studentvm && \
az vm create \
  --location eastus \
  --resource-group studentvm \
  --name project2vm \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --admin-password $PASSWORD && \
PUBLIC_IP=$(az vm show -d -g studentvm -n project2vm --query publicIps -o tsv) && \
ssh azureuser@$PUBLIC_IP
```

0b.   get required installs and docker
``` bash
cd ~ && \
sudo apt-get update && sudo apt-get install -y ca-certificates curl jq python3-pip python3-venv gnupg software-properties-common && \
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && \
# sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
su - $USER
# docker --version
```

0b.   get terraform
``` bash
cd ~
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

0c.   get kubectl
``` bash
cd ~
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# kubectl version --client
```

0d.   get helm
``` bash
cd ~
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
./get_helm.sh
# helm version
```

0d.   get flask-llama-python
``` bash
pip install flask llama-cpp-python waitress locust wonderwords
```

0e.   get azure cli
```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && \
az login --use-device
```

0f.   get handout
``` bash
wget  https://cloudnativehandout.blob.core.windows.net/project2/llmservice-handout.tar.gz
tar -xvzf llmservice-handout.tar.gz
```

---

*.   get azure service principle
```
subscription_id=$(az account list --query "[?isDefault].id" --output tsv) && \
service_principle=($(az ad sp create-for-rbac --role Contributor --scopes /subscriptions/$subscription_id --query "[appId, password, tenant]" --output tsv)) && \
```
