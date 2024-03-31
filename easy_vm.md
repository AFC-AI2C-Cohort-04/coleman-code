## setup rg, vm, and get ip
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

---

## git clone
``` bash
sudo apt-get update && sudo apt-get install git && \
GIT_REPO=<REPO_URL> && \
git clone $GIT_REPO
# git clone -b dev/coleman-zachery $GIT_REPO
# ^ use to clone specific branch

# using ssh

# generate ssh
ssh-keygen -t rsa -b 4096 -C "<description>"

# display ssh key, then copy/paste output to github settings > ssh
cat .ssh/id_rsa.pub

# repo > code > code local clone ssh
git clone git@<url>
```

---

## git python and pip
``` bash
sudo apt-get update && sudo apt-get upgrade -y && \
sudo apt-get install python3 python3-pip -y
```
