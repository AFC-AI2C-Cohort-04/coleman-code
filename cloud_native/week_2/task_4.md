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
cd ~/handout/cloudchat/task2-4-microservices/chat/docker
echo 'FROM openjdk:17-jdk-slim' > Dockerfile
echo 'COPY groupchat-0.1.0.jar groupchat-0.1.0.jar' >> Dockerfile
echo 'ENTRYPOINT ["java", "-jar", "groupchat-0.1.0.jar"]' >> Dockerfile
```

2b.   move .jar file and build chat docker image
```
cd ~/handout/cloudchat/task2-4-microservices/chat/docker
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
cd ~/handout/cloudchat/task2-4-microservices/login/docker
echo 'FROM openjdk:17-jdk-slim' > Dockerfile
echo 'COPY login-0.1.0.jar login-0.1.0.jar' >> Dockerfile
echo 'ENTRYPOINT ["java", "-jar", "login-0.1.0.jar"]' >> Dockerfile
```

2d.   move .jar file and build login docker image
```
cd ~/handout/cloudchat/task2-4-microservices/login/docker
mv ../target/login-0.1.0.jar login-0.1.0.jar
image_name=login
version=latest
container=$image_name:$version
build_path=./
docker build --rm --tag $container $build_path
mv login-0.1.0.jar ../target/login-0.1.0.jar
```

---

3a.   install NGINX ingress controller
```
cd ~
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install my-nginx bitnami/nginx-ingress-controller --version v9.3.24
```

3b.   create ingress.yaml
```
cd ~/handout/cloudchat/task2-4-microservices/task4-ingress
echo -e "apiVersion: networking.k8s.io/v1\nkind: Ingress\nmetadata:
  name: microservices-ingress\nspec:\n  rules:\n  - http:\n      paths:
      - path: /profile\n        pathType: Prefix\n        backend:
          service:\n            name: spring-profile-service\n            port:
              number: 80\n      - path: /chat\n        pathType: Prefix
        backend:\n          service:\n            name: spring-chat-service
            port:\n              number: 80\n      - path: /login
        pathType: Prefix\n        backend:\n          service:
            name: spring-login-service\n            port:
              number: 80" > ingress.yaml
```

3c.   create ingress resource and check state
```
cd ~/handout/cloudchat/task2-4-microservices/task4-ingress
kubectl create -f ingress.yaml && \
kubectl get ingress
```

3d.   delete task 3 kubernetes service
```
cd ~/handout/cloudchat/task2-4-microservices/profile/task3-k8s
kubectl delete -f .
```

---

4.   copy profile k8s config files to helm templates, make updates, and install helm charts
```
cd ~/handout/cloudchat/task2-4-microservices/profile
cp task3-k8s/* task4-helm/profile/templates/
cd task4-helm/profile/templates/
sed -i 's/mysql_db_host:/MYSQL_DB_HOST:/' configmap.yaml
sed -i '/mysql_db_port: "3306"/d' configmap.yaml
sed -i 's/containerPort: 8080/containerPort: 80/' deployment.yaml
sed -i '/containerPort: 80/q' deployment.yaml
echo -e "        envFrom:\n        - configMapRef:
            name: spring-profile-configmap\n        - secretRef:
            name: spring-profile-secret" >> deployment.yaml
sed -i 's/mysql_db_username/MYSQL_DB_USER/g; s/mysql_db_password/MYSQL_DB_PASSWORD/g' secret.yaml
sed -i 's/MYSQL_DB_USER: \(.*\)/MYSQL_DB_USER: "\1"/' secret.yaml
sed -i 's/MYSQL_DB_PASSWORD: \(.*\)/MYSQL_DB_PASSWORD: "\1"/' secret.yaml
echo '  MYSQL_DB_PORT: "3306"' >> secret.yaml
sed -i 's/type: LoadBalancer/type: NodePort/' service.yaml
cd ~/handout/cloudchat/task2-4-microservices/profile
helm install profile task4-helm/profile/
```

# STUCK: CURLING THE EXTERNAL IP OF THE NGINX LOADBALANCER RESULTS IN 404

---

[<< Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_3.md)
