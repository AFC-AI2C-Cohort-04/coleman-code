## Docker Tutorial


0a.   install docker
```
 curl -fsSL https://get.docker.com -o get-docker.sh
 sudo sh get-docker.sh
```

0b.   create docker group, add current user, and activate group, and verify docker is running
```
sudo groupadd docker
sudo usermod -aG docker $(whoami)
newgrp docker
docker run hello-world
```



---

1.   create dockerfile
```
# choose base image
# FROM ubuntu:18.04

# choose base directory path
WORKDIR /app

# add or copy files from host file system
# ADD ./target/app.jar /
# COPY . .

# example of run install commands
# RUN yarn install --production
# RUN apt-get update && apt-get -y install default-jre

# open ports
# EXPOSE 8000

# use bash as the container's entry point
# ENTRYPOINT ["/bin/bash", "-c"]

# define command which runs when the container starts
# CMD ["node", "src/index.js"]
# CMD ["java -cp demo-1.0-SNAPSHOT-jar-with-dependencies.jar HelloWorld"]

# ENTRYPOINT and CMD work together to create a single following command when container starts
# /bin/bash -c "java -cp demo-1.0-SNAPSHOT-jar-with-dependencies.jar HelloWorld"
```

---

2a.   build image
```
cd /path/to/getting-started-app

# example 1
# docker build -t getting-started .

# example 2
# docker build --rm --tag clouduser/primer:latest .
```

2b.   display images
```
docker iamges
```

---

3.   start app container
```
docker run -dp 127.0.0.1:3000:3000 getting-started
# -d runs "detached" (in the background)
# -p maps container port(s) to host port
```

---

4.   list containers/processes
```
docker ps
```

5.   stop container/process
```
docker stop <the-container-id>
docker rm <the-container-id>
```

---

*.   how to uninstall docker
```
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```

*.   enable docker start-up on boot
```
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```
