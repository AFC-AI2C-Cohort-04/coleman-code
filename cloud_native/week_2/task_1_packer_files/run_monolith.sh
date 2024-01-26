export MYSQL_HOST="shared-mysql-fs-fflgmddz.mysql.database.azure.com"
export MYSQL_USER="Monolithic_CloudChat_123"
export MYSQL_PASSWORD="Monolithic_CloudChat_123"
export SPRING_REDIS_HOST="redis-cache-vwuhyibe.redis.cache.windows.net"
export SPRING_REDIS_PORT="6379"
export SPRING_REDIS_PASSWORD="u96gLdbzaA7CQ6OMVzQWLPPmIib2AudURAzCaHF9L7Y="
cd /home/packer
/bin/java -jar ./target/cloudchat-1.0.0.jar
