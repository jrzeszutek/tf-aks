terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.47.0"
    }
  }

  required_version = "~> 0.14"
}

variable "aks_rg" {
  type = string
  description = "Resource group to create AKS in"
}

variable "aks_location" {
  type = string
  description = "Location to create AKS in"
}

variable "aks_name" {
  type = string
  description = "AKS's name"
}

variable "azure_client_id" {
  type = string
  description = "Service Principal Client ID"
}

variable "azure_client_secret" {
  type = string
  description = "Service Principal Client Secret"
}

variable "admin_username" {
  default     = "azureuser"
  type        = string
}

variable "agents_size" {
  default     = "Standard_D2s_v3"
  type        = string
}

variable "agents_count" {
  type        = number
  default     = 2
}

variable "public_key_content" {
  type        = string
  default     = ""
}

variable "tags" {
  type        = map(string)
  default     = {}
}

variable "vnet_subnet_id" {
  type        = string
  default     = null
}

variable "os_disk_size_gb" {
  type        = number
  default     = 50
}

variable "sku_tier" {
   type        = string
  default     = "Free"
}

variable "network_plugin" {
  type        = string
  default     = "kubenet"
}

variable "network_policy" {
  type        = string
  default     = null
}

variable "net_profile_outbound_type" {
  type        = string
  default     = "loadBalancer"
}

variable "kubernetes_version" {
  type        = string
  default     = null
}

variable "agents_pool_name" {
  type        = string
  default     = "nodepool"
}

variable "agents_type" {
  type        = string
  default     = "VirtualMachineScaleSets"
}

variable "load_balancer_sku" {
  type        = string
  default     = "Standard"
}

variable "outbound_ip_address_ids" {
  type        = string
}

variable "dns_prefix" {
  type = string
}

provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                    = var.aks_name
  kubernetes_version      = var.kubernetes_version
  location                = var.aks_location
  resource_group_name     = var.aks_rg
  dns_prefix              = var.dns_prefix
  sku_tier                = var.sku_tier

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = var.public_key_content
    }
  }

  default_node_pool {
    name                  = var.agents_pool_name
    node_count            = var.agents_count
    vm_size               = var.agents_size
    os_disk_size_gb       = var.os_disk_size_gb
    vnet_subnet_id        = var.vnet_subnet_id
    type                  = var.agents_type
  }

  service_principal {
    client_id     = var.azure_client_id
    client_secret = var.azure_client_secret
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    kube_dashboard {
      enabled = true
    }
  }

  network_profile {
    network_plugin      = var.network_plugin
    network_policy      = var.network_policy
    outbound_type       = var.net_profile_outbound_type
    loadBalancerSku     = var.load_balancer_sku
    loadBalancerProfile {
      outbound_ip_address_ids = var.outbound_ip_address_ids
    }
  }

  tags = var.tags
}