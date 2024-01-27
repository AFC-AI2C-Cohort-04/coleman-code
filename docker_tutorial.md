## Docker Tutorial


0a.   install docker
```
 curl -fsSL https://get.docker.com -o get-docker.sh
 sudo sh get-docker.sh
```

0b.   create docker group, add user, and activate group, and verify docker is running
```
sudo groupadd docker
USER=dockeruser
sudo usermod -aG docker $USER
newgrp docker
docker run hello-world
```

0c.   enable docker start-up on boot
```
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

---

1a.   create dockerfile




---

*.   how to uninstall docker
```
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```
