## Cloud Native | Week 2 | Task 1

known red herrings and write-up inconsistencies
- use the same subscription that is used by terraform when it creates the monolith db
- location should be "eastus" not "eastus2"
- change directory name "handout" to "project" to match write-up and provided code
- "azure-packer.pkr.hcl" provided from handout contains false assumptions
- change directory name "task1-monolith" to "monolith" before submitting for task 1

1.   create main resource group and vm (replace password)
```
az group create --name main_rg --location eastus
az vm create \
  --location eastus \
  --resource-group main_rg \
  --name main_vm \
  --image Ubuntu2204 \
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

4.   get handout and change directory name from "handout" to "project"
```
wget https://cloudnativehandout.blob.core.windows.net/project1/handout.tar.gz
tar -xvzf handout.tar.gz
mv ~/handout ~/project
```

5.   get terraform
```
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

6.   get azure cli and login
```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login --use-device-code
```

7.   get maven, kubectl, and helm
```
sudo apt-get install maven openjdk-17-jdk openjdk-17-jre jq -y
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

8.   create monolith db (20~30 minutes)
```
cd ~/project/cloudchat/terraform-setup/task1-monolith_data_tier
terraform init
terraform apply -var-file="secret.tfvars"
```

9.   get db variables and write to "run_monolith.sh"
```
echo "export MYSQL_HOST=$(terraform output mysql_fqdn)" > db_variables.sh
echo "export MYSQL_USER=$(terraform output mysql_admin_username)" >> db_variables.sh
echo "export MYSQL_PASSWORD=$(terraform output mysql_admin_password)" >> db_variables.sh
echo "export SPRING_REDIS_HOST=$(terraform output redis_hostname)" >> db_variables.sh
echo "export SPRING_REDIS_PORT=$(terraform output redis_port)" >> db_variables.sh
echo "export SPRING_REDIS_PASSWORD=$(terraform output redis_primary_access_key)" >> run_monolith.sh
sudo chmod +x run_monolith.sh
sudo source run_monolith.sh
sudo chmod -x run_monolith.sh
echo "cd /home/packer" >> run_monolith.sh
echo "java -jar ./target/cloudchat-1.0.0.jar" >> run_monolith.sh
```

10a.   application login (login once 10b. successfully runs)
```
echo "login with lucas for username and password @ http:$(az vm show -d -g main_rg -n main_vm --query publicIps -o tsv):8080/login"
```

10b.   test application (~5 minutes, ctrl+C after logging in and testing)
```
cd ~/project/cloudchat/task1-monolith
mvn clean package
java -jar ./target/cloudchat-1.0.0.jar
```

11.   get packer and update/replace "run_monolith.sh" with previously written variables
```
cd ~
sudo apt-get install packer
packer plugins install github.com/hashicorp/azure
mv -f ~/project/cloudchat/terraform-setup/task1-monolith_data_tier/db_variables.sh ~/project/cloudchat/task1-monolith/packer/run_monolith.sh
cd ~/project/cloudchat/task1-monolith/packer
```

12.   update file content [azure-packer.pkr.hcl](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/azure-packer.pkr.hcl) in ~/project/cloudchat/task1-monolith/packer/ 

13.   create azure principle and write environment variables to secret.pkrvars.hcl
```
az group create -l eastus -n test_rg
subscription_id=$(az account list --query "[?isDefault].id" --output tsv)
sp_info=($(az ad sp create-for-rbac --role Contributor --scopes /subscriptions/$subscription_id --query "[appId, password, tenant]" --output tsv))
echo client_id=\"${sp_info[0]}\" > secret.pkrvars.hcl
echo client_secret=\"${sp_info[1]}\" >> secret.pkrvars.hcl
echo tenant_id=\"${sp_info[2]}\" >> secret.pkrvars.hcl
echo subscription_id=\"$subscription_id\" >> secret.pkrvars.hcl
```

14.   validate packer build
```
packer validate \
  -var-file="secret.pkrvars.hcl" \
  -var "managed_image_name=test_image" \
  -var "resource_group=test_rg" .
```

15.   perform packer build (~5 minutes)
```
packer build \
  -var-file="secret.pkrvars.hcl" \
  -var "managed_image_name=test_image" \
  -var "resource_group=test_rg" .
```

16.   validate packer build by creating vm from image
```
az vm create \
  --resource-group test_rg \
  --name test_vm \
  --image test_image \
  --admin-username azureuser \
  --generate-ssh-keys
```

17.   get submitter, rename "task1-monolith" directory to "monolith", and submit for task 1 (~10 minutes)
```
cd ~/project
wget https://cloudnativehandout.blob.core.windows.net/project1/submitter && chmod +x submitter
mv ~/project/cloudchat/task1-monolith ~/project/cloudchat/monolith
./submitter task1
```
