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

---

4a.   create deployment.yaml
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

---

[<< Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_2.md)      [Task 4 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_4.md)
