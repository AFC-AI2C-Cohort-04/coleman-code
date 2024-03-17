## quickly and easily setup a vm with these bash commands and display its public ip

``` bash
RG_NAME=my_rg && \
VM_NAME=my_vm && \
PASSWORD=<PASSWORD> && \
az group create \
  --location eastus \
  --name $RG_NAME && \
az vm create \
  --location eastus \
  --resource-group $RG_NAME \
  --name $VM_NAME \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --admin-password $PASSWORD && \
PUBLIC_IP=$(az vm show -d -g $RG_NAME -n $VM_NAME --query publicIps -o tsv) && \
echo $PUBLIC_IP
```
