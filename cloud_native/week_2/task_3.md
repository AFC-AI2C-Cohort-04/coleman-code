## Cloud Native | Week 2 | Task 3

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/start.md)    [Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_1.md)    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_2.md)    Task 3    [Task 4](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_4.md)

---

0a.   create azure container registry (ACR)
```
cd ~
acr_name=acrcloudchat
az group create \
  --name acr_rg \
  --location eastus && \
az acr create \
  --resource-group acr_rg \
  --name $acr_name \
  --sku Basic
```

0b.   login to ACR
```
az acr update \
  --name $acr_name \
  --admin-enabled true && \
az acr login \
  --name $acr_name
```

---

1.   tag and push the container image that was built from task 2
```
image_name=profile
version=latest
container=$image_name:$version
acr_server=$acr_name.azurecr.io
docker tag $container $acr_server/$container && \
docker push $acr_server/$container
```

---

2.   create azure kubernetes (AKS) cluster
```
az group create \
  --name aks_rg \
  --location eastus && \
aks_name=aks-cloudchat && \
az aks create \
  --resource-group aks_rg \
  --name $aks_name \
  --attach-acr $acr_name \
  --node-vm-size "Standard_B2s" \
  --node-count 2 \
  --generate-ssh-keys
```

*.   (how to update/attach a container to AKS cluster)
```
az aks update \
  --name <AKS_NAME> \
  --resource-group <AKS_RG_NAME>\
  --attach-acr <ACR_NAME>
```

---

3.   connect to AKS cluster
```
az aks get-credentials \
  --resource-group aks_rg \
  --name $aks_name && \
kubectl get nodes
```

*.   try re-installing kubectl if 'command kubectl not found'
```
cd ~
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

---

4a.   create configmap.yaml (update UUID)
```
cd ~/handout/cloudchat/task2-4-microservices/profile/task3-k8s
sql_db_name=$(az resource list --query "[?starts_with(name, 'profile-mysql-fs')].resourceGroup" -o tsv) && \
echo -e "apiVersion: v1\nkind: ConfigMap\nmetadata:
  name: spring-profile-configmap\ndata:
  mysql_db_host: \"${sql_db_name}.mysql.database.azure.com\"
  mysql_db_port: \"3306\"" > configmap.yaml
```

4b.   create deployment.yaml
```
cd ~/handout/cloudchat/task2-4-microservices/profile/task3-k8s
echo -e "apiVersion: apps/v1\nkind: Deployment\nmetadata:
  name: spring-profile-deployment\n  labels:\n    app: profile\nspec:
  replicas: 3\n  selector:\n    matchLabels:\n      app: profile\n  template:
    metadata:\n      labels:\n        app: profile\n    spec:\n      containers:
      - name: profile\n        image: $acr_server/$container\n        ports:
        - containerPort: 8080\n        env:\n        - name: MYSQL_DB_HOST
          valueFrom:\n            configMapKeyRef:
              name: spring-profile-configmap\n              key: mysql_db_host
        - name: MYSQL_DB_PORT\n          valueFrom:
            configMapKeyRef:\n              name: spring-profile-configmap
              key: mysql_db_port\n        - name: MYSQL_DB_USER
          valueFrom:\n            secretKeyRef:
              name: spring-profile-secret\n              key: mysql_db_username
        - name: MYSQL_DB_PASSWORD\n          valueFrom:
            secretKeyRef:\n              name: spring-profile-secret
              key: mysql_db_password" > deployment.yaml
```

4c.   create secret.yaml
```
cd ~/handout/cloudchat/terraform-setup/task2-3-profile_data_tier
MYSQL_DB_USER=$(terraform output -raw mysql_admin_username)
MYSQL_DB_PASSWORD=$(terraform output -raw mysql_admin_password)
cd ~/handout/cloudchat/task2-4-microservices/profile/task3-k8s
echo -e "apiVersion: v1\nkind: Secret\nmetadata:\n  name: spring-profile-secret
type: Opaque\nstringData:\n  mysql_db_username: ${MYSQL_DB_USER}
  mysql_db_password: ${MYSQL_DB_PASSWORD}" > secret.yaml
```

4d.   create service.yaml
```
cd ~/handout/cloudchat/task2-4-microservices/profile/task3-k8s
echo -e "apiVersion: v1\nkind: Service\nmetadata:
  name: spring-profile-service\nspec:\n  selector:\n    app: profile\n  ports:
    - port: 80\n      targetPort: 8080\n  type: LoadBalancer" > service.yaml
```

---

5a.   deploy profile application to AKS cluster
```
cd ~/handout/cloudchat/task2-4-microservices/profile/task3-k8s
kubectl apply -f .
```

5b.   verify profile service
```
LOAD_BALANCER_EXTERNAL_IP=$(kubectl get service spring-profile-service --output=jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$LOAD_BALANCER_EXTERNAL_IP/profile?username=lucas
```

*.   (troubleshooting steps / commands)
```
# list all services in the default namespace (ensure load balancer external ip exists)
kubectl get services

# list all pods in the default namespace
kubectl get pods

# retrieve the logs for a specific pod
kubectl logs <POD_NAME>

# exec command will give you the terminal access inside of the pod
kubectl exec -it <POD_NAME> -- /bin/sh
```

---

6a.   export submission credentials and run submitter
```
export SUBMISSION_USERNAME=<USERNAME>
export SUBMISSION_PASSWORD=<PASSWORD>
cd ~/handout
./submitter task3
```

6b.   delete task 3 kubernetes service
```
cd ~/handout/cloudchat/task2-4-microservices/profile/task3-k8s
kubectl delete -f .
```

---

[<< Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_2.md)      [Task 4 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_4.md)

