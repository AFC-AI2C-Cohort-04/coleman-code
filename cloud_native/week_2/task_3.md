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
#az acr login \
  --name $ACR_SERVER_NAME \
  -u $ACR_USERNAME \
  -p $ACR_PASSWORD
```

---

[<< Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_2.md)      [Task 4 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_2/task_4.md)
