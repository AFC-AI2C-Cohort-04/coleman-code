## Data Engineering | Week 3 | Start

Start

---

0a.   create resource group and vm (change password)
```
az group create --name relational-databases --location eastus
az vm create \
    --resource-group relational-databases \
    --name dataeng2 \
    --size Standard_B2ms \
    --image Canonical:0001-com-ubuntu-server-focal:20_04-lts:latest \
    --admin-username clouduser \
    --admin-password <YOUR_PASSWORD>
```

0b.   ssh login to vm
```
vm_ip=$(az network public-ip show -g relational-databases -n dataeng2PublicIP --query ipAddress -o tsv)
echo $vm_ip
ssh clouduser@$vm_ip
```

---

