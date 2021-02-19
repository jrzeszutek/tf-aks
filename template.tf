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

provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.aks_location
  resource_group_name = var.aks_rg
  dns_prefix          = "${var.aks_name}-k8s"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_B2s"
    os_disk_size_gb = 30
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
}