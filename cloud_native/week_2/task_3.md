## Cloud Native | Week 2 | Task 3

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/start.md)    [Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_1.md)    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_2.md)    Task 3    [Task 4](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_4.md)

---

0a.   create azure container registry (ACR)
```
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
assignee=$(az ad signed-in-user show --query id -o tsv) && \
subscription_id=$(az account show --query id -o tsv) && \
scope1="/subscriptions/$subscription_id/resourceGroups/acr_rg" && \
scope2="providers/Microsoft.ContainerRegistry/registries/acrprofile" && \
az role assignment create \
  --assignee $assignee \
  --role Owner \
  --scope $scope1/$scope2 && \
az login --use-device-code && \
az acr login \
  --name acrprofile
```

---

1.   tag and push the container image that was built from task 2
```
image_name=profile
version=latest
container=$image_name:$version
acr_server=$acr_name.azurecr.io
docker tag $container $acr_server/$container
docker push $acr_server/$container
```

2.   create azure kubernetes cluster (AKS)
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

[<< Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_2.md)      [Task 4 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_4.md)
