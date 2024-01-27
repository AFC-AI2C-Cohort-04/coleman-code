## Docker Tutorial


0a.   install docker
```
 curl -fsSL https://get.docker.com -o get-docker.sh
 sudo sh get-docker.sh
```

*.   how to uninstall docker
```
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```

---

1a.   ssh into vm and authenticate with password
```
ssh azureuser@$(az vm show -d -g main_rg -n main_vm --query publicIps -o tsv)
```
