packer {
  required_plugins {
    azure = {
      version = ">= 2.0.2"
      source  = "github.com/hashicorp/azure"
    }
  }
}

variable "client_id" {
  type = string
  default = null
}

variable "client_secret" {
  type = string
  default = null
}

variable "tenant_id" {
  type = string
  default = null
}

variable "subscription_id" {
  type = string
  default = null
}

variable "resource_group" {
  type = string
  default = "test_rg"
}

variable "managed_image_name" {
  type = string
  default = "test_image"
}

variable "mysql_host" {
  type = string
  default = null
}

variable "mysql_user" {
  type = string
  default = null
}

variable "mysql_password" {
  type = string
  default = null
}

variable "spring_redis_host" {
  type = string
  default = null
}

variable "spring_redis_port" {
  type = string
  default = null
}

variable "spring_redis_password" {
  type = string
  default = null
}

variable "location" {
  type = string
  default = "eastus2"
}

variable "vm_os_type" {
  type = string
  default = "Linux" 
}

variable "vm_image_publisher" {
  type = string
  default = "Canonical" 
}

variable "vm_image_offer" {
  type = string
  default = "0001-com-ubuntu-server-jammy" 
}

variable "vm_image_sku" {
  type = string
  default = "22_04-lts" 
}

variable "vm_size" {
  type = string
  default = "Standard_B2s"
}

source "azure-arm" "main" {
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  location = var.location
  managed_image_resource_group_name = var.resource_group
  managed_image_name = var.managed_image_name
  os_type = var.vm_os_type
  image_publisher = var.vm_image_publisher
  image_offer = var.vm_image_offer
  image_sku = var.vm_image_sku
  vm_size = var.vm_size
}

build {
  sources = [
    "source.azure-arm.main"
  ]

  provisioner "file" {
    source = "myapp.service"
    destination = "/home/packer/myapp.service"
  }

  provisioner "file" {
    source = "run_monolith.sh"
    destination = "/home/packer/run_monolith.sh"
  }

  provisioner "file" {
    source = "../pom.xml"
    destination = "/home/packer/pom.xml"
  }

  provisioner "file" {
    source = "../src"
    destination = "/home/packer/src"
  }

  provisioner "shell" {
    environment_vars = [
      "MYSQL_HOST=${var.mysql_host}",
      "MYSQL_USER=${var.mysql_user}",
      "MYSQL_PASSWORD=${var.mysql_password}",
      "SPRING_REDIS_HOST=${var.spring_redis_host}",
      "SPRING_REDIS_PORT=${var.spring_redis_port}",
      "SPRING_REDIS_PASSWORD=${var.spring_redis_password}"
    ]
    inline = [
      "cloud-init status --wait",
      "sudo apt update",
      "sudo apt install -y maven openjdk-17-jdk openjdk-17-jre jq",
      "sudo chmod +x run_monolith.sh",
      "chmod 644 myapp.service",
      "sudo cp myapp.service /etc/systemd/system/myapp.service",
      "sudo systemctl enable myapp.service",
      "mvn clean package"
    ]
  }
}
