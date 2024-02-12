## MongoDB Tutorial

0a.   create vm and login with password
``` bash
PASSWORD=<PASSWORD> && \
az group create --name mongo_rg --location eastus && \
az vm create \
  --resource-group mongo_rg \
  --name mongo_vm \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username azureuser \
  --admin-password $PASSWORD && \
PUBLIC_IP=$(az vm show -d -g mongo_rg -n mongo_vm --query publicIps -o tsv) && \
ssh azureuser@$PUBLIC_IP
```

0b.   install and start mongo
``` bash
sudo apt-get update && sudo apt-get install gnupg curl && \
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor && \
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list && \
sudo apt-get update && sudo apt-get install -y mongodb-org && \
sudo systemctl start mongod && \
mongosh

```

*.   misc.
``` bash
sudo systemctl status mongod # check status
sudo systemctl stop mongod # stop
sudo systemctl daemon-reload # reload
sudo systemctl enable mongod # auto-start on boot
```

---

1a.   
``` bash

```

---

*.   uninstall mongo
``` bash
sudo service mongod stop
sudo apt-get purge "mongodb-org*"
sudo rm -r /var/log/mongodb
sudo rm -r /var/lib/mongodb
```
