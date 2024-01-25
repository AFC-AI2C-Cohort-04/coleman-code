packer {
  required_plugins {
    azure = {
      version = ">= 2.0.2"
      source  = "github.com/hashicorp/azure"
    }
  }
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
    source      = "myapp.service"
    destination = "/home/packer/myapp.service"
  }

  provisioner "file" {
    source      = "run_monolith.sh"
    destination = "/home/packer/run_monolith.sh"
  }

  provisioner "file" {
    source      = "../pom.xml"
    destination = "/home/packer/pom.xml"
  }

  provisioner "file" {
    source      = "../src"
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
