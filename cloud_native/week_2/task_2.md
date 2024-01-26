## Cloud Native | Week 2 | Task 2

success steps
- [_______] terraform builds db

1.   create profile db
```
cd ~/project/cloudchat/terraform-setup/task2-3-profile_data_tier
terraform init
terraform apply -var-file="secret.tfvars"
```

2.   write terraform output to "db_variables.sh", run as source
```
cd ~/project/cloudchat/terraform-setup/task2-3-profile_data_tier
echo "export MYSQL_HOST=\"$(terraform output -raw mysql_fqdn)\"" > db_variables.sh
echo "export MYSQL_USER=\"$(terraform output -raw mysql_admin_username)\"" >> db_variables.sh
echo "export MYSQL_PASSWORD=\"$(terraform output -raw mysql_admin_password)\"" >> db_variables.sh
sudo chmod +x db_variables.sh
source ./db_variables.sh
```



3.   create a Dockerfile to containerize the Profile service.
```
cd ~/project/cloudchat/task2-4-microservices/profile/task2-docker

```
