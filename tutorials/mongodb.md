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
```

*.   misc.
``` bash
sudo systemctl status mongod # check status
sudo systemctl stop mongod # stop
sudo systemctl daemon-reload # reload
sudo systemctl enable mongod # auto-start on boot
```

---

1.   get sample data and enter mongo shell
``` bash
wget https://raw.githubusercontent.com/mongodb/docs-assets/primer-dataset/primer-dataset.json && \
sudo mkdir -p /data/db && sudo chown -R $USER /data/db && \
mongoimport --db mongo_primer --collection restaurants --drop --file primer-dataset.json && \
mongosh
```

---

2a.   set working database
```
show dbs
use mongo_primer
show collections
```

2b.   example queries
```
db.restaurants.findOne()
db.restaurants.find({"address.street" : "Flatbush Avenue"})
db.restaurants.find({"grades.grade" : "A"})
db.restaurants.find({"grades.score" : { $gt: 50}})
db.restaurants.find({"grades.score" : { $gt: 50}, "borough": "Manhattan"})
db.restaurants.find({$or: [{"grades.score" : {$gt: 50}}, {"borough": "Manhattan"}]})
```

2c.   query that finds 10 restaurants on Flatbush Avenue with scores above 30
```
db.restaurants.find({"address.street":"Flatbush Avenue", "grades.score":{$gt:30}}).limit(10)
```

---

3a.   get db indexes
```
db.restaurants.getIndexes()
```

3b.   make/drop an index (borough_1)
```
db.restaurants.createIndex({"borough":1})
db.restaurants.dropIndex({"borough":1})
```

3c.   query using index
```
db.restaurants.find( { "borough": "San Francsico" }).explain("executionStats")
```

---

*.   uninstall mongo
``` bash
sudo service mongod stop
sudo apt-get purge "mongodb-org*"
sudo rm -r /var/log/mongodb
sudo rm -r /var/lib/mongodb
```
