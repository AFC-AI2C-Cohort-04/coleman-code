## Cloud Native | Week 2 | Task 3

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/start.md)    [Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_1.md)    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_2.md)    Task 3    [Task 4](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_4.md)

---

0a.   create azure container registry (ACR)
```
az group create \
  --name acr_rg \
  --location eastus && \
az acr create \
  --resource-group acr_rg \
  --name acrprofile \
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

[<< Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_2.md)      [Task 4 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_4.md)
