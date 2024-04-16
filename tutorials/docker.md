## Docker Tutorial


0a.   install docker
```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# install latest version
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

0b.   create test directory, create docker group, add current user, activate group, and verify docker is running
```
# sudo groupadd docker # should already exist
sudo usermod -aG docker $USER
newgrp docker
su - $USER # re-enter password if prompted
docker --version # will display if working
# mkdir ~/docker_test && cd ~/docker_test
# docker run hello-world
```

---

1.   get example handout and package app
```
wget https://s3.amazonaws.com/cmucc-public/container-detail/sample-containerized-webservice.tgz -O sample-containerized-webservice.tgz
tar -xvzf sample-containerized-webservice.tgz
sudo apt-get install -y maven
mvn clean package
```

---

2.   configure dockerfile (handout reference below is pre-configured)
```
# base image
FROM ubuntu:18.04

# run install commands
RUN apt-get update && apt-get -y install default-jre

# open container port
EXPOSE 80

# add or copy files from host file system
ADD ./target/demo-1.0-SNAPSHOT-jar-with-dependencies.jar /

# use bash as the container's entry point
ENTRYPOINT ["/bin/bash", "-c"]

# define command which runs when the container starts
CMD ["java -cp demo-1.0-SNAPSHOT-jar-with-dependencies.jar HelloWorld"]

# ENTRYPOINT and CMD work together to create a single following command when container starts
# /bin/bash -c "java -cp demo-1.0-SNAPSHOT-jar-with-dependencies.jar HelloWorld"

# base directory path for image (not used in this example)
# WORKDIR /app

# copy can also be used to add files from host file system
# COPY . .
```

---

3a.   build docker image from docker file
```
# --rm removes previous version
dockerfile_path=./
image_name=image_test
version=latest
container=$image_name:$version
build_path=./
docker build --rm -f $dockerfile_path -t $container $build_path
```

3b.   display / delete images
```
docker images

# delete docker images (container must be stopped and removed first)
docker_image=<image_id>
docker rmi $docker_image
```

---

4.   start app container from docker image
```
host_port=8000
cont_port=8080
docker run -d -p $host_port:$cont_port $container
# wait a few seconds, then curl
my_ip=$(curl ifconfig.me)
curl $my_ip:$host_port
# -d runs "detached" (in the background)
# -p maps container port(s) to host port
```

---

5.   list/stop/delete containers/processes
```
docker ps
docker ps -a # (list all containers/processess including stopped)
docker stop <container-id> # stops container/process
docker rm <container-id> # deletes container/process
```

---

*.   (run docker image in interactive mode)
```
docker run -it <image_id> /bin/sh
```

*.   (how to uninstall docker)
```
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

*.   (how to enable docker start-up on boot)
```
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```
