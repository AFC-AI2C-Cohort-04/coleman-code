## Cloud Native | Week 2 | Task 4

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/start.md)    [Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_1.md)    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_2.md)    [Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_3.md)    Task 4

---

0a.   create chat db
```
cd ~/handout/cloudchat/terraform-setup/task4-chat_data_tier
terraform init
terraform apply -var-file="secret.tfvars"
```

0b.   create login db
```
cd ~/handout/cloudchat/terraform-setup/task4-login_data_tier
terraform init
terraform apply -var-file="secret.tfvars"
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

2b.   build chat docker image
```
cd ~/handout/cloudchat/task2-4-microservices/chat/docker
mv ../target/groupchat-0.1.0.jar groupchat-0.1.0.jar
image_name=chat
version=latest
container=$image_name:$version
build_path=./
docker build --rm --tag $container $build_path && \
mv groupchat-0.1.0.jar ../target/groupchat-0.1.0.jar
```

2c.   tag and push chat container
```
acr_name=acrcloudchat
acr_server=$acr_name.azurecr.io
docker tag $container $acr_server/$container && \
docker push $acr_server/$container
```

2d.   configure login Dockerfile
```
cd ~/handout/cloudchat/task2-4-microservices/login/docker
echo 'FROM openjdk:17-jdk-slim' > Dockerfile
echo 'COPY login-0.1.0.jar login-0.1.0.jar' >> Dockerfile
echo 'ENTRYPOINT ["java", "-jar", "login-0.1.0.jar"]' >> Dockerfile
```

2e.   build login docker image
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

2f.   tag and push login container
```
acr_name=acrcloudchat
acr_server=$acr_name.azurecr.io
docker tag $container $acr_server/$container && \
docker push $acr_server/$container
```

---

3a.   get helm and NGINX ingress controller
```
cd ~
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
helm repo add bitnami https://charts.bitnami.com/bitnami && \
helm repo update && \
helm install my-nginx bitnami/nginx-ingress-controller --version v9.3.24
```

3b.   create ingress.yaml
```
cd ~/handout/cloudchat/task2-4-microservices/task4-ingress
echo -e "apiVersion: networking.k8s.io/v1\nkind: Ingress\nmetadata:
  name: microservices-ingress\nspec:\n  ingressClassName: nginx\n  rules:
  - http:\n      paths:\n      - path: /profile\n        pathType: Prefix
        backend:\n          service:\n            name: spring-profile-service
            port:\n              number: 80\n      - path: /chat
        pathType: Prefix\n        backend:\n          service:
            name: spring-chat-service\n            port:
              number: 80\n      - path: /login\n        pathType: Prefix
        backend:\n          service:\n            name: spring-login-service
            port:\n              number: 80" > ingress.yaml
```

3c.   create ingress resource and check state
```
cd ~/handout/cloudchat/task2-4-microservices/task4-ingress
kubectl apply -f ingress.yaml && \
kubectl get ingress
```

---

4a.   create profile helm files and install helm profile
```
cd ~/handout/cloudchat/task2-4-microservices/profile
cp task3-k8s/* task4-helm/profile/templates/
cd task4-helm/profile/templates/
sed -i 's/containerPort: 8080/containerPort: 80/' deployment.yaml && \
sed -i 's/type: LoadBalancer/type: NodePort/' service.yaml && \
cd ~/handout/cloudchat/task2-4-microservices/profile && \
helm install profile task4-helm/profile/
```

4b.   verify profile service (should return JSON)
```
LOAD_BALANCER_EXTERNAL_IP=$(kubectl get services -o json | jq -r '.items[] | select(.spec.type == "LoadBalancer") | .status.loadBalancer.ingress[].ip // .status.loadBalancer.ingress[].hostname')
curl http://$LOAD_BALANCER_EXTERNAL_IP/profile?username=lucas
```

*.   (ingress & helm troubleshooting)
```
# (3a., 3b., 3c.) re-install ingress controller, update ingress file, and create ingress profile

# show cluster services
kubectl get services

# show helm services
helm list

# remove helm service
helm delete <name>
```

---

5.   create RBAC for chat service
```
cd ~/handout/cloudchat/task2-4-microservices/task4-rbac/
kubectl apply -f .
```

---

6a.   get chat db variables
```
cd ~/handout/cloudchat/terraform-setup/task4-chat_data_tier
export CHAT_DB_HOST="$(terraform output -raw mysql_fqdn)" && \
export CHAT_DB_PORT="3306" && \
export CHAT_DB_USER="$(terraform output -raw mysql_admin_username)" && \
export CHAT_DB_PASSWORD="$(terraform output -raw mysql_admin_password)" && \
export CHAT_REDIS_HOST="$(terraform output -raw redis_hostname)" && \
export CHAT_REDIS_PORT="$(terraform output -raw redis_port)" && \
export CHAT_REDIS_PASSWORD="$(terraform output -raw redis_primary_access_key)"
```

6b.   create chat helm files and install helm chat
```
cd ~/handout/cloudchat/task2-4-microservices/
cp profile/task4-helm/profile/templates/* chat/helm/chat/templates/
cd chat/helm/chat/templates/
sed -i 's/profile/chat/g' configmap.yaml
sed -i '/^data:/q' configmap.yaml
echo -e "  MYSQL_DB_HOST: \"$CHAT_DB_HOST\"
  SPRING_REDIS_HOST: \"$CHAT_REDIS_HOST\"" >> configmap.yaml
sed -i 's/profile/chat/g' deployment.yaml
sed -i 's/profile/chat/g' secret.yaml
sed -i '/^stringData:/q' secret.yaml
echo -e "  MYSQL_DB_PORT: \"$CHAT_DB_PORT\"\n  MYSQL_DB_USER: \"$CHAT_DB_USER\"
  MYSQL_DB_PASSWORD: \"$CHAT_DB_PASSWORD\"
  SPRING_REDIS_PORT: \"$CHAT_REDIS_PORT\"
  SPRING_REDIS_PASSWORD: \"$CHAT_REDIS_PASSWORD\"" >> secret.yaml
sed -i 's/profile/chat/g' service.yaml
cd ~/handout/cloudchat/task2-4-microservices/chat
helm install chat helm/chat/
```

6c.   verify chat service (should return JSON)
```
curl http://$LOAD_BALANCER_EXTERNAL_IP/chat
```

---

7a.   get login db variables
```
cd ~/handout/cloudchat/terraform-setup/task4-login_data_tier
export LOGIN_DB_HOST="$(terraform output -raw mysql_fqdn)" && \
export LOGIN_DB_PORT="3306" && \
export LOGIN_DB_USER="$(terraform output -raw mysql_admin_username)" && \
export LOGIN_DB_PASSWORD="$(terraform output -raw mysql_admin_password)"
```

7b.   create login helm files and install helm login
```
cd ~/handout/cloudchat/task2-4-microservices/
cp profile/task4-helm/profile/templates/* login/helm/login/templates/
cd login/helm/login/templates/
sed -i 's/profile/login/g' configmap.yaml
sed -i '/^data:/q' configmap.yaml
echo -e "  MYSQL_DB_HOST: \"$LOGIN_DB_HOST\"
  MYSQL_DB_PORT: \"$LOGIN_DB_PORT\"
  CHAT_ENDPOINT: \"$LOAD_BALANCER_EXTERNAL_IP\"" >> configmap.yaml
sed -i 's/profile/login/g' deployment.yaml
sed -i 's/profile/login/g' secret.yaml
sed -i '/^stringData:/q' secret.yaml
echo -e "  MYSQL_DB_USER: \"$LOGIN_DB_USER\"
  MYSQL_DB_PASSWORD: \"$LOGIN_DB_PASSWORD\"" >> secret.yaml
sed -i 's/profile/login/g' service.yaml
cd ~/handout/cloudchat/task2-4-microservices/login
helm install login helm/login/
```

7c.   verify login service by going to login webpage
```
echo http://$LOAD_BALANCER_EXTERNAL_IP/login
```

---

8.   export submission credentials and run submitter
```
export SUBMISSION_USERNAME=<USERNAME>
export SUBMISSION_PASSWORD=<PASSWORD>
cd ~/handout
./submitter task4
```

---

[<< Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_3.md)
