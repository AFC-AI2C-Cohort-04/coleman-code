## Docker Tutorial


0a.   install docker
```
cd ~
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
```

0b.   create test directory, create docker group, add current user, activate group, and verify docker is running
```
sudo groupadd docker # should already exist
sudo usermod -aG docker $USER
newgrp docker
su - $USER # re-enter password
mkdir ~/docker_test && cd ~/docker_test
docker run hello-world
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
image_name=image_test
version=latest
container=$image_name:$version
dockerfile_path=./
docker build --rm --tag $container $dockerfile_path
```

3b.   display / delete images
```
docker images

# delete docker images (container must be stopped and removed first)
docker_image=<image_id>
docker rmi $docker_image
```

---

4.   start app container from image
```
my_ip=$(curl ifconfig.me)
docker run -d -p 8080:80 $image_name:$version
# wait a few seconds
curl $my_ip:8080
# -d runs "detached" (in the background)
# -p maps container port(s) to host port
```

---

5.   list/stop/delete containers/processes
```
docker ps
docker ps -a # (list all containers/processess including stopped)
container=<container-id>
docker stop $container # stops container/process
docker rm $container # deletes container/process
```

---

*.   how to uninstall docker
```
cd ~
sudo systemctl stop docker
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
```
```
sudo rm get-docker.sh
sudo rm -rf docker_test
sudo rm -rf /etc/docker
sudo rm -rf /etc/default/docker
sudo rm -rf /var/lib/docker
sudo rm -rf /var/run/docker.sock
sudo rm -rf /var/run/docker.pid
sudo rm -rf /var/run/docker
sudo rm -rf /var/lib/containerd
sudo delgroup docker
sudo rm $(which docker)
```

*.   how to enable docker start-up on boot
```
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```
