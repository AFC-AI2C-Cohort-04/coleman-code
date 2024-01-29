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
# export MYSQL_DB_HOST="$(terraform output -raw mysql_fqdn)"
# export MYSQL_DB_USER="$(terraform output -raw mysql_admin_username)"
# export MYSQL_DB_PASSWORD="$(terraform output -raw mysql_admin_password)"
# export MYSQL_DB_PORT="3306"
```

---

[<< Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_3.md)
