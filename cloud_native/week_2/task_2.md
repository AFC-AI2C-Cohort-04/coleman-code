## Cloud Native | Week 2 | Task 2

[<< Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/start.md)    [<< Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_1.md)

0a.   create profile db (~5 minutes)
```
cd ~/handout/cloudchat/terraform-setup/task2-3-profile_data_tier
terraform init
terraform apply -var-file="secret.tfvars"
```

0b.   get db variables
```
cd ~/handout/cloudchat/terraform-setup/task2-3-profile_data_tier
export MYSQL_DB_HOST="$(terraform output -raw mysql_fqdn)"
export MYSQL_DB_USER="$(terraform output -raw mysql_admin_username)"
export MYSQL_DB_PASSWORD="$(terraform output -raw mysql_admin_password)"
export MYSQL_DB_PORT="3306"
```

1a.   install docker
```
cd ~
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
```

1b.   create docker group, add current user, activate group, refresh session, and verify docker is running
```
sudo groupadd docker # should already exist
sudo usermod -aG docker $USER
newgrp docker
su - $USER # re-enter password
docker --version
```

---

2.   compile the application using maven
```
cd ~/handout/cloudchat/task2-4-microservices/profile
mvn clean package
```

---

3.   configure Dockerfile
```
cd ~/handout/cloudchat/task2-4-microservices/profile/task2-docker
echo 'FROM openjdk:17-jdk-slim' > Dockerfile
echo 'WORKDIR /app' >> Dockerfile
echo 'COPY ../target/profile-0.1.0.jar /app/profile-0.1.0.jar' >> Dockerfile
echo 'ENTRYPOINT ["java", "-jar", "/app/profile-0.1.0.jar"]' >> Dockerfile
echo 'EXPOSE 3306' >> Dockerfile
```

---

4.   build docker image
```
dockerfile_path=./
image_name=profile
version=latest
container=$image_name:$version
build_path=./
docker build --rm -f $dockerfile_path -t $container $build_path
```



