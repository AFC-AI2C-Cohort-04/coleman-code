# file goes in ~/handout/cloudchat/task1-monolith/packer
export MYSQL_HOST=$(terraform output -raw mysql_fqdn)
export MYSQL_USER=$(terraform output -raw mysql_admin_username)
export MYSQL_PASSWORD=$(terraform output -raw mysql_admin_password)
export SPRING_REDIS_HOST=$(terraform output -raw redis_hostname)
export SPRING_REDIS_PASSWORD=$(terraform output -raw redis_primary_access_key)
export SPRING_REDIS_PORT=$(terraform output -raw redis_port)
cd /home/packer/cloudchat/task1-monolith/
/bin/java -jar ./target/cloudchat-1.0.0.jar
