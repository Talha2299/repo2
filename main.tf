terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "aks_demo" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks_demo" { 
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.aks_demo.name
  location            = azurerm_resource_group.aks_demo.location
  dns_prefix          = var.dns_prefix

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = "${trimspace(tls_private_key.key.public_key_openssh)} ${var.admin_username}@azure.com"
    }
  }

  default_node_pool {
    name       = "default"
    node_count = var.agent_count
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

resource "tls_private_key" "key" {
  algorithm   = "RSA"
}

resource "null_resource" "save-key" {
  triggers = {
    key = tls_private_key.key.private_key_pem
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.module}/.ssh
      echo "${tls_private_key.key.private_key_pem}" > ${path.module}/.ssh/id_rsa
      chmod 0600 ${path.module}/.ssh/id_rsa
EOF
  }
}


output "id" {
    value = azurerm_kubernetes_cluster.aks_demo.id
}

