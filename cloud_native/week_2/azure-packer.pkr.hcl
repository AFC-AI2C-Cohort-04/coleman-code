variable "resource_group" {
  type = string
  default = ""
}

variable "managed_image_name" {
  type = string
  default = ""
}

source "azure-arm" "main" {
  client_id = "7ddc2442-34e6-4c88-beb9-7a945b0566b5"
  client_secret = "Uqf8Q~NqctAThiGtsBonTnWveo~DNsxrVxVUuaxN"
  tenant_id = "7054bedc-f003-44d5-841f-cb36c2f8de54"
  subscription_id = "78a0ba1b-e701-4e60-9794-8d8f104c454c"

  managed_image_resource_group_name = var.resource_group
  managed_image_name = var.managed_image_name

  location = "eastus"
  os_type = "Linux"
  image_publisher = "Canonical"
  image_offer = "0001-com-ubuntu-server-jammy"
  image_sku = "22_04-lts"
  vm_size = "Standard_B2s"
}

build {
  sources = [
    "source.azure-arm.main"
  ]

  provisioner "file" {
    source      = "/home/azureuser/handout/cloudchat/monolith/target/cloudchat-1.0.0.jar"
    destination = "cloudchat-1.0.0.jar"
  }

  provisioner "shell" {
    inline = [
      "cloud-init status --wait",
      "sudo apt update",
      "sudo apt install -y openjdk-17-jdk openjdk-17-jre jq",
      "export MYSQL_HOST=\"shared-mysql-fs-duepnhee.mysql.database.azure.com\"",
      "export MYSQL_USER=\"Monolithic_CloudChat_123\"",
      "export MYSQL_PASSWORD=\"Monolithic_CloudChat_123\"",
      "export SPRING_REDIS_HOST=\"redis-cache-ewqntvzm.redis.cache.windows.net\"",
      "export SPRING_REDIS_PORT=\"6379\"",
      "export SPRING_REDIS_PASSWORD=\"hUZdj6ly0nfYDiaZ8fY4pR7HVSkev188tAzCaGQGe7U=\"",
      "sudo cp cloudchat-1.0.0.jar /opt/cloudchat-1.0.0.jar",
      "sudo tee /etc/systemd/system/cloudchat.service <<EOF",
      "[Unit]",
      "Description=CloudChat Service",
      "After=network.target",
      "",
      "[Service]",
      "User=root",
      "Environment=\"MYSQL_HOST=$MYSQL_HOST\"",
      "Environment=\"MYSQL_USER=$MYSQL_USER\"",
      "Environment=\"MYSQL_PASSWORD=$MYSQL_PASSWORD\"",
      "Environment=\"SPRING_REDIS_HOST=$SPRING_REDIS_HOST\"",
      "Environment=\"SPRING_REDIS_PORT=$SPRING_REDIS_PORT\"",
      "Environment=\"SPRING_REDIS_PASSWORD=$SPRING_REDIS_PASSWORD\"",
      "ExecStart=/usr/bin/java -jar /opt/cloudchat-1.0.0.jar",
      "Restart=always",
      "",
      "[Install]",
      "WantedBy=multi-user.target",
      "EOF",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable cloudchat.service",
      "sudo systemctl start cloudchat.service"
    ]
  }
}
