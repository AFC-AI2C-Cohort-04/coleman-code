variable "client_id" {
  type    = string
  default = ""
  sensitive = true
}

variable "client_secret" {
  type    = string
  default = ""
  sensitive = true
}

variable "tenant_id" {
  type    = string
  default = ""
  sensitive = true
}

variable "subscription_id" {
  type    = string
  default = ""
  sensitive = true
}

variable "mysql_host" {
  type    = string
  default = ""
  sensitive = true
}

variable "mysql_user" {
  type    = string
  default = ""
  sensitive = true
}

variable "mysql_password" {
  type    = string
  default = ""
  sensitive = true
}

variable "spring_redis_host" {
  type    = string
  default = ""
  sensitive = true
}

variable "spring_redis_port" {
  type    = string
  default = ""
  sensitive = true
}

variable "spring_redis_password" {
  type    = string
  default = ""
  sensitive = true
}

variable "resource_group" {
  type = string
  default = ""
}

variable "managed_image_name"{
  type = string
  default = ""
}

source "azure-arm" "main" {
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
  managed_image_resource_group_name = var.resource_group
  managed_image_name = var.managed_image_name
  location = "East US 2"
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
    source = "/home/azureuser/handout/cloudchat/task1-monolith/packer/myapp.service"
    destination = "/home/packer/myapp.service"
  }

  provisioner "file" {
    source = "/home/azureuser/handout/cloudchat/task1-monolith/packer/run_monolith.sh"
    destination = "/home/packer/run_monolith.sh"
  }

  provisioner "file" {
    source = "/home/azureuser/handout/cloudchat/task1-monolith/pom.xml"
    destination = "/home/packer/pom.xml"
  }

  provisioner "file" {
    source = "/home/azureuser/handout/cloudchat/task1-monolith/src"
    destination = "/home/packer/src"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIANT_FRONTEND=noninteractive",
      "MYSQL_HOST=${var.mysql_host}",
      "MYSQL_USER=${var.mysql_user}",
      "MYSQL_PASSWORD=${var.mysql_password}",
      "SPRING_REDIS_HOST=${var.spring_redis_host}",
      "SPRING_REDIS_PORT=${var.spring_redis_port}",
      "SPRING_REDIS_PASSWORD=${var.spring_redis_password}"
    ]
    inline = [
      "cloud-init status --wait",
      "sudo apt-get update",
      "sudo apt-get install -y maven openjdk-17-jdk openjdk-17-jre jq",
      "sudo chmod +x run_monolith.sh",
      "chmod 644 myapp.service",
      "sudo cp myapp.service /etc/systemd/system/myapp.service",
      "sudo systemctl enable myapp.service",
      "mvn clean package",
      "sudo systemctl stop myapp.service",
      "sudo systemctl start myapp.service"
    ]
  }
}
