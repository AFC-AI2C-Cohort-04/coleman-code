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
    destination = "/tmp/myapp.service"
  }

  provisioner "file" {
    source = "/home/azureuser/project/cloudchat/task1-monolith/packer/run_monolith.sh"
    destination = "/tmp/run_monolith.sh"
  }

  provisioner "file" {
    source = "/home/azureuser/project/cloudchat/task1-monolith/target/cloudchat-1.0.0.jar"
    destination = "/tmp/cloudchat-1.0.0.jar"
  }

  provisioner "shell" {
    environment_vars = [
      "client_id=${var.client_id}",
      "client_secret=${var.client_secret}",
      "tenant_id=${var.tenant_id}",
      "subscription_id=${var.subscription_id}",
      "managed_image_resource_group_name=${var.resource_group}",
      "managed_image_name=${var.managed_image_name}",
    ]
    inline = [
      "cloud-init status --wait",
      "sudo apt-get update",
      "sudo apt-get install -y openjdk-17-jdk",
      "sudo apt-get install -y maven",
      "cp /tmp/run_monolith.sh .",
      "sudo mv /tmp/myapp.service /etc/systemd/system/myapp.service",
      "sudo chmod +x run_monolith.sh",
      "chmod 644 /etc/systemd/system/myapp.service",
      "sudo systemctl enable myapp.service",
      "/bin/java -jar <path>/cloudchat-1.0.0.jar",
    ]
  }
}
