## Cloud Native | Week 2 | Setup

1.   create main resource group and vm (replace password)
```
az group create --name main_rg --location eastus2 && \
az vm create \
  --resource-group main_rg \
  --location eastus2 \
  --name main_vm \
  --image Canonical:0001-com-ubuntu-server-focal:20_04-lts-gen2:latest \
  --size Standard_B2s \
  --admin-username azureuser \
  --admin-password <PASSWORD>
```

2.   open ports on vm
```
az vm open-port --resource-group main_rg --name main_vm --port 22 --priority 1001
az vm open-port --resource-group main_rg --name main_vm --port 8000 --priority 1002
az vm open-port --resource-group main_rg --name main_vm --port 8080 --priority 1003
```

3.   ssh into vm and authenticate with password
```
ssh azureuser@$(az vm show -d -g main_rg -n main_vm --query publicIps -o tsv)
```

4.   get azure cli and login
```
cd ~
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login --use-device-code
```

5.   get handout
```
cd ~
wget https://cloudnativehandout.blob.core.windows.net/project1/handout.tar.gz
tar -xvzf handout.tar.gz
```

6.   get terraform
```
cd ~
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform
```

7.   get maven, kubectl, and helm
```
cd ~
sudo apt-get install maven openjdk-17-jdk openjdk-17-jre jq -y
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```
