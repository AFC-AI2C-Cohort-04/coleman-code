## Cloud Native | Week 2 | Task 1

1.   create monolith db (~25 minutes)
```
cd ~/handout/cloudchat/terraform-setup/task1-monolith_data_tier
terraform init
terraform apply -var-file="secret.tfvars"
```

2.   write db variables to "run_monolith.sh", run as source
```
cd ~/handout/cloudchat/terraform-setup/task1-monolith_data_tier
echo "export MYSQL_HOST=\"$(terraform output -raw mysql_fqdn)\"" > run_monolith.sh
echo "export MYSQL_USER=\"$(terraform output -raw mysql_admin_username)\"" >> run_monolith.sh
echo "export MYSQL_PASSWORD=\"$(terraform output -raw mysql_admin_password)\"" >> run_monolith.sh
echo "export SPRING_REDIS_HOST=\"$(terraform output -raw redis_hostname)\"" >> run_monolith.sh
echo "export SPRING_REDIS_PORT=\"$(terraform output -raw redis_port)\"" >> run_monolith.sh
echo "export SPRING_REDIS_PASSWORD=\"$(terraform output -raw redis_primary_access_key)\"" >> run_monolith.sh
sudo chmod +x run_monolith.sh
source ./run_monolith.sh
sudo chmod -x run_monolith.sh
```

3a.   generate application url for login (login once 3b. successfully runs)
```
echo "login with lucas for username and password @ http:$(az vm show -d -g main_rg -n main_vm --query publicIps -o tsv):8080/login"
```

3b.   test application (~5 minutes, ctrl+C after done with testing)
```
cd ~/handout/cloudchat/task1-monolith
mvn clean package
java -jar ./target/cloudchat-1.0.0.jar
```

4.   get packer and write "run_monolith.sh"
```
cd ~
sudo apt-get install packer
packer plugins install github.com/hashicorp/azure
mv ~/handout/cloudchat/terraform-setup/task1-monolith_data_tier/run_monolith.sh ~/handout/cloudchat/task1-monolith/packer/run_monolith.sh
cd ~/handout/cloudchat/task1-monolith/packer
echo "cd /home/packer" >> run_monolith.sh
echo "/bin/java -jar ./target/cloudchat-1.0.0.jar" >> run_monolith.sh
```

5.   update file contents [azure-packer.pkr.hcl](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_1_packer_files/azure-packer.pkr.hcl) in ~/handout/cloudchat/task1-monolith/packer/

6.   create azure principle, and write environment variables to secret.pkrvars.hcl
```
cd ~/handout/cloudchat/task1-monolith/packer
subscription_id=$(az account list --query "[?isDefault].id" --output tsv) && \
az group create -l eastus -n test_rg && \
sp_info=($(az ad sp create-for-rbac --role Contributor --scopes /subscriptions/$subscription_id --query "[appId, password, tenant]" --output tsv))
echo "client_id = \"${sp_info[0]}\"" > secret.pkrvars.hcl
echo "client_secret = \"${sp_info[1]}\"" >> secret.pkrvars.hcl
echo "tenant_id = \"${sp_info[2]}\"" >> secret.pkrvars.hcl
echo "subscription_id = \"$subscription_id\"" >> secret.pkrvars.hcl
echo "mysql_host = \"${MYSQL_HOST}\"" >> secret.pkrvars.hcl
echo "mysql_user = \"${MYSQL_USER}\"" >> secret.pkrvars.hcl
echo "mysql_password = \"${MYSQL_PASSWORD}\"" >> secret.pkrvars.hcl
echo "spring_redis_host = \"${SPRING_REDIS_HOST}\"" >> secret.pkrvars.hcl
echo "spring_redis_port = \"${SPRING_REDIS_PORT}\"" >> secret.pkrvars.hcl
echo "spring_redis_password = \"${SPRING_REDIS_PASSWORD}\"" >> secret.pkrvars.hcl
```

7.   validate packer build
```
cd ~/handout/cloudchat/task1-monolith/packer
packer validate \
  -var-file="secret.pkrvars.hcl" \
  -var "managed_image_name=test_image" \
  -var "resource_group=test_rg" .
```

8.   perform packer build (~5 minutes)
```
cd ~/handout/cloudchat/task1-monolith/packer
packer build \
  -var-file="secret.pkrvars.hcl" \
  -var "managed_image_name=test_image" \
  -var "resource_group=test_rg" .
```

9.   validate packer build by creating vm from image
```
az vm create \
  --location eastus2 \
  --resource-group test_rg \
  --name test_vm \
  --image test_image \
  --admin-username azureuser \
  --generate-ssh-keys
```

10.   export your submission credentials are run submitter (~10 minutes)
```
cd ~/handout
wget https://cloudnativehandout.blob.core.windows.net/project1/submitter && chmod +x submitter
export SUBMISSION_USERNAME=<USERNAME>
export SUBMISSION_PASSWORD=<PASSWORD>
./submitter task1
```
