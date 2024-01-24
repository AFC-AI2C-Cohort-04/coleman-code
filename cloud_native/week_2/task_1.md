## Cloud Native | Week 2 | Task 1

***fails at 15. perform packer build***

1.   create main resource group and vm (replace password)
```
az group create --name main_rg --location eastus2
az vm create \
  --location eastus2 \
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

4.   get handout and change directory name to project
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

8.   set-up monolith db (20~30 minutes)
```
cd ~/project/cloudchat/terraform-setup/task1-monolith_data_tier
terraform init
terraform apply -var-file="secret.tfvars"
```

9.   get db variables and write to file
```
echo "export MYSQL_HOST=\"$(terraform output -raw mysql_fqdn)\"" > db_variables.sh
echo "export MYSQL_USER=\"$(terraform output -raw mysql_admin_username)\"" >> db_variables.sh
echo "export MYSQL_PASSWORD=\"$(terraform output -raw mysql_admin_password)\"" >> db_variables.sh
echo "export SPRING_REDIS_HOST=\"$(terraform output -raw redis_hostname)\"" >> db_variables.sh
echo "export SPRING_REDIS_USER=\"$(terraform output -raw redis_port)\"" >> db_variables.sh
echo "export SPRING_REDIS_PASSWORD=\"$(terraform output -raw redis_primary_access_key)\"" >> db_variables.sh
chmod +x db_variables.sh
source db_variables.sh
chmod -x db_variables.sh
echo "cd /home/packer" >> db_variables.sh
echo "nohup java -jar ./target/cloudchat-1.0.0.jar &" >> db_variables.sh
```

10a.   application login (wait to login after you do 11b.)
```
echo "login with lucas for username and password @ http:$(az vm show -d -g main_rg -n main_vm --query publicIps -o tsv):8080/login"
```

10b.   test application (ctrl+C when done)
```
cd ~/project/cloudchat/task1-monolith
mvn clean package
java -jar ./target/cloudchat-1.0.0.jar
```

11.   get packer
```
cd ~
sudo apt-get install packer
packer plugins install github.com/hashicorp/azure
mv -f ~/project/cloudchat/terraform-setup/task1-monolith_data_tier/db_variables.sh ~/project/cloudchat/task1-monolith/packer/run_monolith.sh
cd ~/project/cloudchat/task1-monolith/packer
```

12.   update file [azure-packer.pkr.hcl](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/azure-packer.pkr.hcl) in ~/project/cloudchat/task1-monolith/packer/ 

13.   create azure principle and write environment variables to secret.pkrvars.hcl
```
az group create -l eastus2 -n test_rg
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
  -var "managed_image_name=test_vm" \
  -var "resource_group=test_rg" .
```

15.   perform packer build (fails to load context for cloudchat app)
```
packer build \
  -var-file="secret.pkrvars.hcl" \
  -var "managed_image_name=test_vm" \
  -var "resource_group=test_rg" .
```

16.   connect to virtual machine and validate
```
az vm create \
  --resource-group test_rg \
  --name test_vm \
  --image Ubuntu2204 \
  --admin-username azureuser \
  --generate-ssh-keys
```

17.   task 1 submitter
```
cd ~/project
wget https://cloudnativehandout.blob.core.windows.net/project1/submitter && chmod +x submitter
./submitter task1
```
