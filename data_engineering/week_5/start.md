## Data Engineering | Week 5 | Start

Start    [Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_5/task_1.md)    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_5/task_2.md)

[MongoDB Tutorial](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/tutorials/mongodb.md)

---

0a.   create password, vm, and login
```
VM_PASSWORD=<PASSWORD> && \
az group create \
  --location eastus \
  --name multi-model-databases && \
az vm create \
    --resource-group multi-model-databases \
    --name multimodelengg \
    --size Standard_B2ms \
    --image Ubuntu2204 \
    --admin-username azureuser \
    --admin-password $VM_PASSWORD && \
PUBLIC_IP=$(az vm show -d -g multi-model-databases -n multimodelengg --query publicIps -o tsv) && \
ssh azureuser@$PUBLIC_IP
```

0b.   get handout
```
cd ~/ && \
wget https://clouddataengineer.blob.core.windows.net/multi-model-databases/handout/multi-model-databases.gz && \
tar -xvzf multi-model-databases.gz && \
chmod -R 777 multi-model-databases/
```

0c.   get requirements
```
cd ~/multi-model-databases/ && \
sudo add-apt-repository -y ppa:deadsnakes/ppa && \
sudo apt-get update && sudo apt install -y python3.10 python3-pip && \
pip install -r requirements.txt
```

0d.   get and start mongo
``` bash
sudo apt-get update && sudo apt-get install gnupg curl && \
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor && \
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list && \
sudo apt-get update && sudo apt-get install -y mongodb-org && \
sudo systemctl start mongod
```

---

[Task 1 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_5/task_1.md)
