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

*.   (ensure docker is installed and user has docker privileges)

---

1.   compile chat and login applications with maven
```
cd ~/handout/cloudchat/task2-4-microservices/chat
mvn clean package
cd ~/handout/cloudchat/task2-4-microservices/login
mvn clean package
```

---

2a.   configure chat Dockerfile
```
cd ~/handout/cloudchat/task2-4-microservices/chat/task2-docker
echo 'FROM openjdk:17-jdk-slim' > Dockerfile
echo 'COPY groupchat-0.1.0.jar groupchat-0.1.0.jar' >> Dockerfile
echo 'ENTRYPOINT ["java", "-jar", "groupchat-0.1.0.jar"]' >> Dockerfile
```

2b.   move .jar file and build chat docker image
```
cd ~/handout/cloudchat/task2-4-microservices/chat/task2-docker
mv ../target/groupchat-0.1.0.jar groupchat-0.1.0.jar
image_name=chat
version=latest
container=$image_name:$version
build_path=./
docker build --rm --tag $container $build_path
mv groupchat-0.1.0.jar ../target/groupchat-0.1.0.jar
```

2c.   configure login Dockerfile
```
cd ~/handout/cloudchat/task2-4-microservices/login/task2-docker
echo 'FROM openjdk:17-jdk-slim' > Dockerfile
echo 'COPY login-0.1.0.jar login-0.1.0.jar' >> Dockerfile
echo 'ENTRYPOINT ["java", "-jar", "login-0.1.0.jar"]' >> Dockerfile
```

2d.   move .jar file and build login docker image
```
cd ~/handout/cloudchat/task2-4-microservices/login/task2-docker
mv ../target/login-0.1.0.jar login-0.1.0.jar
image_name=login
version=latest
container=$image_name:$version
build_path=./
docker build --rm --tag $container $build_path
mv login-0.1.0.jar ../target/login-0.1.0.jar
```

---

[<< Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_3.md)
