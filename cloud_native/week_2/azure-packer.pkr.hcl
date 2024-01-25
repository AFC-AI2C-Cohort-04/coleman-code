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
  vm_size = "Standard_B2s"
  location = "eastus"
}

build {
  sources = [
    "source.azure-arm.example"
  ]

  # remove /home/azureuser/project/cloudchat/task1-monolith/packer/ from source paths
  # change /tmp/ to /home/packer/ for destination paths
  provisioner "file" {
    source = "myapp.service"
    destination = "/home/packer/myapp.service"
  }

  provisioner "file" {
    source = "run_monolith.sh"
    destination = "/home/packer/run_monolith.sh"
  }

  provisioner "file" {
    source = "../src"
    destination = "/home/packer/src"
  }

  provisioner "file" {
    source = "../target"
    destination = "/home/packer/target"

  provisioner "shell" {
    environment_vars = [
      "MYSQL_HOST=${var.MYSQL_HOST}",
      "MYSQL_USER=${var.MYSQL_USER}",
      "MYSQL_PASSWORD=${var.MYSQL_PASSWORD}",
      "SPRING_REDIS_HOST=${var.SPRING_REDIS_HOST}",
      "SPRING_REDIS_PORT=${var.SPRING_REDIS_PORT}",
      "SPRING_REDIS_PASSWORD=${var.SPRING_REDIS_PASSWORD}"
    ]
    inline = [
      "cloud-init status --wait",
      "sudo apt-get update",
      "sudo apt-get install -y openjdk-17-jdk",
      "sudo mv myapp.service /etc/systemd/system/myapp.service",
      "sudo chmod +x run_monolith.sh",
      "chmod 644 /etc/systemd/system/myapp.service",
      "sudo systemctl enable myapp.service"
      # Maven build sequence not needed
    ]
  }
}
