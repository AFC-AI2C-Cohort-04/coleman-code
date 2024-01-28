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

3a.   configure .env file
```
cd ~/handout/cloudchat/task2-4-microservices/profile/task2-docker
echo "MYSQL_DB_HOST=\"${MYSQL_DB_HOST}\"" > .env
echo "MYSQL_DB_USER=\"${MYSQL_DB_USER}\"" >> .env
echo "MYSQL_DB_PASSWORD=\"${MYSQL_DB_PASSWORD}\"" >> .env
echo "MYSQL_DB_PORT=\"${MYSQL_DB_PORT}\"" >> .env
```

---

3b.   configure Dockerfile
```
cd ~/handout/cloudchat/task2-4-microservices/profile/task2-docker
echo 'FROM openjdk:17-jdk-slim' > Dockerfile
echo 'WORKDIR /app' >> Dockerfile
echo 'COPY ../target/profile-0.1.0.jar /app/profile-0.1.0.jar' >> Dockerfile
echo 'ENTRYPOINT ["java", "-jar", "/app/profile-0.1.0.jar"]' >> Dockerfile
echo 'EXPOSE 3306' >> Dockerfile
```

---

4a.   move .jar file and build docker image
```
cd ~/handout/cloudchat/task2-4-microservices/profile/task2-docker
mv ../target/profile-0.1.0.jar profile-0.1.0.jar
image_name=profile
version=latest
container=$image_name:$version
build_path=./
docker build --rm --tag $container $build_path
mv profile-0.1.0.jar ../target/profile-0.1.0.jar
```

---

4b.   run docker container
```
cd ~/handout/cloudchat/task2-4-microservices/profile/task2-docker
docker run -d -p 8000:8080 --env-file .env $container
```

5.   connect to container
```
my_ip=$(curl ifconfig.me)
curl $my_ip:8000/profile?username=lucas
```


