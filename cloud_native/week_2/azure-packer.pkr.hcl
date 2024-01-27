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

source "azure-arm" "main" {
  client_id                         = var.client_id
  client_secret                     = var.client_secret
  tenant_id                         = var.tenant_id
  subscription_id                   = var.subscription_id
  managed_image_resource_group_name = var.resource_group
  managed_image_name                = var.managed_image_name
  location                          = "eastus" # submitter needs 'eastus'
  os_type                           = "Linux"
  image_publisher                   = "Canonical"
  image_offer                       = "0001-com-ubuntu-server-jammy"
  image_sku                         = "22_04-lts"
  vm_size                           = "Standard_B2s" # submitter will ignore and create 'Standard_DS1_v2'
}

build {
  sources = [
    "source.azure-arm.main"
  ]

  provisioner "file" {
    source      = "myapp.service"
    destination = "/etc/systemd/system/myapp.service"
  }

  provisioner "file" {
    source      = "../target/cloudchat-1.0.0.jar"
    destination = "/home/packer/cloudchat-1.0.0.jar"
  }

  provisioner "shell" {
    inline = [
      "cloud-init status --wait",
      "sudo apt-get update",
      "sudo apt-get install -y openjdk-17-jdk openjdk-17-jre jq",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable myapp.service",
      "sudo systemctl start myapp.service"
    ]
  }
}
