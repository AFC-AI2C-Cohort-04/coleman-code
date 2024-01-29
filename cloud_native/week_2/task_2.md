## Cloud Native | Week 2 | Task 2

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/start.md)    [Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_1.md)    Task 2    [Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_3.md)    [Task 4](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_4.md)

[(Docker Tutorial)](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/docker_tutorial.md)

---

0a.   create profile db (~5 minutes)
```
cd ~/handout/cloudchat/terraform-setup/task2-3-profile_data_tier
terraform init
terraform apply -var-file="secret.tfvars"
```

0b.   get db variables
```
cd ~/handout/cloudchat/terraform-setup/task2-3-profile_data_tier
export MYSQL_DB_HOST="$(terraform output -raw mysql_fqdn)" && \
export MYSQL_DB_USER="$(terraform output -raw mysql_admin_username)" && \
export MYSQL_DB_PASSWORD="$(terraform output -raw mysql_admin_password)" && \
export MYSQL_DB_PORT="3306"
```

---

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

3a.   configure Dockerfile
```
cd ~/handout/cloudchat/task2-4-microservices/profile/task2-docker
echo 'FROM openjdk:17-jdk-slim' > Dockerfile && \
echo 'COPY profile-0.1.0.jar profile-0.1.0.jar' >> Dockerfile && \
echo 'ENTRYPOINT ["java", "-jar", "profile-0.1.0.jar"]' >> Dockerfile
```

3b.   move .jar file and build docker image
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

3c.   configure .env file
```
cd ~/handout/cloudchat/task2-4-microservices/profile/task2-docker
echo "MYSQL_DB_HOST=${MYSQL_DB_HOST}" > .env && \
echo "MYSQL_DB_USER=${MYSQL_DB_USER}" >> .env && \
echo "MYSQL_DB_PASSWORD=${MYSQL_DB_PASSWORD}" >> .env && \
echo "MYSQL_DB_PORT=${MYSQL_DB_PORT}" >> .env
```

---

4a.   run docker container
```
cd ~/handout/cloudchat/task2-4-microservices/profile/task2-docker
host_port=8000
cont_port=8080
docker run -d -p $host_port:$cont_port --env-file .env $container
```

4b.   test connection to container
```
vm_ip=$(curl ifconfig.me)
curl $vm_ip:$host_port/profile?username=lucas
```

*.   troubleshooting if connecting fails:
- (0b.) refresh db variables
- (1b.) ensure you have docker permissions
- (3c.) ensure db variables exist in .env file
- delete process and image, and then rebuild and test (4a., 4b.)
---

5.   export submission credentials and run submitter
```
export SUBMISSION_USERNAME=<USERNAME>
export SUBMISSION_PASSWORD=<PASSWORD>
cd ~/handout
./submitter task2
```

---

[<< Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_1.md)    [Task 3 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_3.md)
