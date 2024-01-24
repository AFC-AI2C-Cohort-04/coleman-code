# file goes in ~/project/cloudchat/task1-monolith/packer
variable "client_id" {
  type = string
  default = ""
  sensitive = true
}

variable "client_secret" {
  type = string
  default = ""
  sensitive = true
}

variable "tenant_id" {
  type = string
  default = ""
  sensitive = true
}

variable "subscription_id" {
  type = string
  default = ""
  sensitive = true
}

variable "resource_group" {
  type = string
  default = ""
}

variable "managed_image_name" {
  type = string
  default = ""
}

variable "MYSQL_HOST" {
  type = string
  default = ""
}

variable "MYSQL_USER" {
  type = string
  default = ""
}

variable "MYSQL_PASSWORD" {
  type = string
  default = ""
}

variable "SPRING_REDIS_HOST" {
  type = string
  default = ""
}

variable "SPRING_REDIS_PORT" {
  type = string
  default = ""
}

variable "SPRING_REDIS_PASSWORD" {
  type = string
  default = ""
}

source "azure-arm" "example" {
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
  managed_image_resource_group_name = var.resource_group
  managed_image_name = var.managed_image_name
  os_type = "Linux"
  image_publisher = "canonical"
  image_offer = "0001-com-ubuntu-server-jammy"
  image_sku = "22_04-lts"
  location = "East US 2"
  vm_size = "Standard_B2s"
}

build {
  sources = [
    "source.azure-arm.example"
  ]

  provisioner "file" {
    source = "/home/azureuser/project/cloudchat/task1-monolith/packer/myapp.service"
    destination = "/home/project/myapp.service"
  }

  provisioner "file" {
    source = "/home/azureuser/project/cloudchat/task1-monolith/packer/run_monolith.sh"
    destination = "/home/project/run_monolith.sh"
  }

  provisioner "file" {
    source = "/home/azureuser/project/cloudchat/task1-monolith/src"
    destination = "/home/project/src"
  }

  provisioner "file" {
    source = "/home/azureuser/project/cloudchat/task1-monolith/pom.xml"
    destination = "/home/project/pom.xml"
  }

  provisioner "shell" {
    environment_vars = [
      "MYSQL_HOST=${var.mysql_host}",
      "MYSQL_USER=${var.mysql_user}",
      "MYSQL_PASSWORD=${var.mysql_password}",
      "SPRING_REDIS_HOST=${var.spring_redis_host}",
      "SPRING_REDIS_PORT=${var.spring_redis_port}",
      "SPRING_REDIS_PASSWORD=$(var.spring_redis_password}"
    ]
    inline = [
      "cloud-init status --wait",
      "sudo chmod +x run_monolith.sh",
      "sudo chmod 644 myapp.service",
      "sudo apt update",
      "sudo apt install -y maven openjdk-17-jdk openjdk-17-jre jq",
      "sudo cp myapp.service /etc/systemd/system/myapp.service",
      "sudo systemctl enable myapp.service",
      "mvn clean package",
      "./run_monolith.sh"
    ]
  }
}
