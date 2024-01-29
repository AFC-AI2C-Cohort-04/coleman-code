## Cloud Native | Week 2 | Task 4

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/start.md)    [Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_1.md)    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_2.md)    [Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_3.md)    Task 4

---

0a.   create chat db
```
cd ~/handout/cloudchat/terraform-setup/task4-chat_data_tier
terraform init
terraform apply -var-file="secret.tfvars"
```

0b.   get chat db variables
```
cd ~/handout/cloudchat/terraform-setup/task4-chat_data_tier
export CHAT_DB_HOST="$(terraform output -raw mysql_fqdn)"
export CHAT_DB_USER="$(terraform output -raw mysql_admin_username)"
export CHAT_DB_PASSWORD="$(terraform output -raw mysql_admin_password)"
export CHAT_REDIS_HOST="$(terraform output -raw redis_hostname)"
export CHAT_REDIS_PORT="$(terraform output -raw redis_port)"
export CHAT_REDIS_PASSWORD="$(terraform output -raw redis_primary_access_key)"
```

0c.   create login db
```
cd ~/handout/cloudchat/terraform-setup/task4-login_data_tier
terraform init
terraform apply -var-file="secret.tfvars"
```

0d.   get login db variables
```
export LOGIN_DB_HOST="$(terraform output -raw mysql_fqdn)"
export LOGIN_DB_USER="$(terraform output -raw mysql_admin_username)"
export LOGIN_DB_PASSWORD="$(terraform output -raw mysql_admin_password)"
export LOGIN_DB_PORT="3001"
```

---

[<< Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_3.md)
