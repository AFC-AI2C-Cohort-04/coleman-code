## Data Engineering | Week 7 | Start

Start    [Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/task_1.md)    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_5/task_7.md)

---

0.    create vm and login
```
PASSWORD=<PASSWORD> && \
az group create \
  --location eastus \
  --name az_group && \
az vm create \
  --location eastus \
  --resource-group az_group \
  --name az_vm \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --admin-password $PASSWORD && \
PUBLIC_IP=$(az vm show -d -g az_group -n az_vm --query publicIps -o tsv) && \
ssh azureuser@$PUBLIC_IP
```

---
