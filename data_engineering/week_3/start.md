## Data Engineering | Week 3 | Start

Start

---

0a.   create resource group and vm (change password)
```
export RESOURCE_GROUP_NAME="relational-databases"
az group create --name $RESOURCE_GROUP_NAME --location eastus
az vm create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name dataengg2 \
    --size Standard_B2ms \
    --image Canonical:0001-com-ubuntu-server-focal:20_04-lts:latest \
    --admin-username clouduser \
    --admin-password <YOUR_PASSWORD>
```

0b.   ssh login to vm
```
vm_ip=
```

---

