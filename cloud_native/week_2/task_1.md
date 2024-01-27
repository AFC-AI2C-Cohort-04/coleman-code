## Cloud Native | Week 2 | Task 1

[<< Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/start.md)

1.   create monolith db (~25 minutes)
```
cd ~/handout/cloudchat/terraform-setup/task1-monolith_data_tier
terraform init
terraform apply -var-file="secret.tfvars"
```

2.   get db variables (used by maven during build test, and needed by java file to connect)
```
cd ~/handout/cloudchat/terraform-setup/task1-monolith_data_tier
export MYSQL_HOST="$(terraform output -raw mysql_fqdn)"
export MYSQL_USER="$(terraform output -raw mysql_admin_username)"
export MYSQL_PASSWORD="$(terraform output -raw mysql_admin_password)"
export SPRING_REDIS_HOST="$(terraform output -raw redis_hostname)"
export SPRING_REDIS_PORT="$(terraform output -raw redis_port)"
export SPRING_REDIS_PASSWORD="$(terraform output -raw redis_primary_access_key)"
```

3a.   generate application url for login (login once 3b. successfully runs)
```
echo -e "\nlogin with lucas for username and password @ $(az vm show -d -g main_rg -n main_vm --query publicIps -o tsv):8080/login\n"
```

3b.   test application (~5 minutes, ctrl+C after done with testing)
```
cd ~/handout/cloudchat/monolith
mvn clean package
java -jar ./target/cloudchat-1.0.0.jar
```

4.   get packer
```
cd ~
sudo apt-get install packer
packer plugins install github.com/hashicorp/azure
```

5.   update [azure-packer.pkr.hcl](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/azure-packer.pkr.hcl) in ~/handout/cloudchat/monolith/packer/

6.   update myapp.service
```
cd ~/handout/cloudchat/monolith/packer
echo "[Unit]" > myapp.service
echo "Description=Cloudchat Service" >> myapp.service
echo "After=network.target" >> myapp.service
echo "" >> myapp.service
echo "[Service]" >> myapp.service
echo "User=root" >> myapp.service
echo "Environment=\"MYSQL_HOST=$MYSQL_HOST\"" >> myapp.service
echo "Environment=\"MYSQL_USER=$MYSQL_USER\"" >> myapp.service
echo "Environment=\"MYSQL_PASSWORD=$MYSQL_PASSWORD\"" >> myapp.service
echo "Environment=\"SPRING_REDIS_HOST=$SPRING_REDIS_HOST\"" >> myapp.service
echo "Environment=\"SPRING_REDIS_PORT=$SPRING_REDIS_PORT\"" >> myapp.service
echo "Environment=\"SPRING_REDIS_PASSWORD=$SPRING_REDIS_PASSWORD\"" >> myapp.service
echo "ExecStart=java -jar /home/packer/cloudchat-1.0.0.jar" >> myapp.service
echo "Restart=always" >> myapp.service
echo "" >> myapp.service
echo "[Install]" >> myapp.service
echo "WantedBy=multi-user.target" >> myapp.service
```

7.   create azure principle, and update secret.pkrvars.hcl
```
cd ~/handout/cloudchat/monolith/packer
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

8.   validate packer build
```
cd ~/handout/cloudchat/monolith/packer
packer validate \
  -var-file="secret.pkrvars.hcl" \
  -var "managed_image_name=test_image" \
  -var "resource_group=test_rg" .
```

9.   perform packer build (~5 minutes)
```
cd ~/handout/cloudchat/monolith/packer
packer build \
  -var-file="secret.pkrvars.hcl" \
  -var "managed_image_name=test_image" \
  -var "resource_group=test_rg" .
```

10.   validate packer build by creating vm from image
```
az vm create \
  --location eastus2 \
  --resource-group test_rg \
  --name test_vm \
  --image test_image \
  --admin-username azureuser \
  --generate-ssh-keys
az vm open-port --resource-group test_rg --name test_vm --port 8080 --priority 1010
```

11.   export your submission credentials are run submitter (~10 minutes)
```
cd ~/handout
wget https://cloudnativehandout.blob.core.windows.net/project1/submitter && chmod +x submitter
export SUBMISSION_USERNAME=<USERNAME>
export SUBMISSION_PASSWORD=<PASSWORD>
./submitter task1
```
