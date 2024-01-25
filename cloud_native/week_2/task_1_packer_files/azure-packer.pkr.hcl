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
      "MYSQL_HOST=shared-mysql-fs-dnigtfhq.mysql.database.azure.com",
      "MYSQL_USER=Monolithic_CloudChat_123",
      "MYSQL_PASSWORD=Monolithic_CloudChat_123",
      "SPRING_REDIS_HOST=redis-cache-rkgqfapa.redis.cache.windows.net",
      "SPRING_REDIS_PORT=6379",
      "SPRING_REDIS_PASSWORD=gHkEOlaYhIOrp7EGp1ZX0nWMZdFU6iOKRAzCaF5zzWM="
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
