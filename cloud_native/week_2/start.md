## Cloud Native | Week 2 | Start

Start    [Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_1.md)    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_2.md)    [Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_3.md)    [Task 4](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_4.md)

---

0a.   create main resource group and vm (change password)
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

0b.   open ports on vm
```
az vm open-port --resource-group main_rg --name main_vm --port 22 --priority 1001 && \
az vm open-port --resource-group main_rg --name main_vm --port 8000 --priority 1002 && \
az vm open-port --resource-group main_rg --name main_vm --port 8080 --priority 1003
```

---

1a.   ssh into vm and authenticate with password
```
vm_ip=$(az vm show -d -g main_rg -n main_vm --query publicIps -o tsv)
ssh azureuser@$vm_ip
```

1b.   get azure cli and login
```
cd ~
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login --use-device-code
```

---

2a.   get handout and submitter, rename 'task1-monolith' to 'monolith' (uses the original submitter)
```
cd ~
wget https://cloudnativehandout.blob.core.windows.net/project1/handout.tar.gz
tar -xvzf handout.tar.gz
chmod +x ./handout/submitter
mv ~/handout/cloudchat/task1-monolith ~/handout/cloudchat/monolith
```

2b.   get terraform
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

2c.   get maven, kubectl
```
cd ~
sudo apt-get install maven openjdk-17-jdk openjdk-17-jre jq -y
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

---

[Task 1 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_1.md)
