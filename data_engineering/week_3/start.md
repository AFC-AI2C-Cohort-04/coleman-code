## Data Engineering | Week 3 | Start

Start

---

0a.   create resource group and vm (change password)
```
az group create --name relational-databases --location eastus
az vm create \
    --resource-group relational-databases \
    --name dataengg2 \
    --size Standard_B2ms \
    --image Canonical:0001-com-ubuntu-server-focal:20_04-lts:latest \
    --admin-username clouduser \
    --admin-password <YOUR_PASSWORD>
```

0b.   ssh login to vm
```
vm_ip=$(az network public-ip show -g relational-databases -n dataengg2PublicIP --query ipAddress -o tsv)
echo $vm_ip
ssh clouduser@$vm_ip
```

0c.   get handout
```
wget https://clouddataengineer.blob.core.windows.net/relational-databases-1/relational-databases-1.tgz
tar -xvzf relational-databases-1.tgz
rm relational-databases-1.tgz
mkdir relational-databases-1/
tar -xvzf pdatabase.tgz -C relational-databases-1/
rm pdatabase.tgz
chmod -R 777 relational-databases-1/
```

---

[Task 1 >>]()
