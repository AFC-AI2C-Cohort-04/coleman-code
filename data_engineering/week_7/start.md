## Data Engineering | Week 7 | Start

Start    [Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/task_1.md)    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/task_2.md)    [Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/task_3.md)    [Task 4](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/task_4.md)

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

1.   get handout
```
wget https://clouddataengineer.blob.core.windows.net/large-scale-batch-processing/handout/sail2/v2/large-scale-batch-processing.zip && \
sudo apt update && \
sudo apt install unzip && \
unzip large-scale-batch-processing.zip
```

---

2a.   provision azure databricks workspace
```
# In the Azure portal, search for 'Azure Databricks'
# Click 'Create azure databricks service'
# Name it and create it
# Open the resource and click 'Launch Workspace'
```

2b.   connect to az databricks workspace
```
sudo apt update && sudo apt install -y python3-pip jq && \
curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sudo sh && \
databricks --version
```

2c.   get databricks token
```
# In the Databricks workspace UI, select User settings from the drop down menu that appears after clicking your user name in the top right corner.
# Click Developer in the Settings menu on the left.
# Click the Manage button next to the Access tokens.
# Generate new token and note it down.
```

2d.   configure databricks token
```
databricks configure --token
# copy/paste https://eastus.azuredatabricks.net/
# copy/paste token
```

*.   verify
```
databricks workspace list /
```

---

3.   run databricks start scripts
```
cd ~/large-scale-batch-processing/
chmod +x databricks-setup.sh && ./databricks-setup.sh && \
databricks workspace import-dir ./starter-code/ /
```

---

[Task 1 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_7/task_1.md)
