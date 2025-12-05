terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc05"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }
  }
}

variable "pm_api_url" {
  type        = string
  description = "Proxmox API URL"
}

variable "pm_api_token_id" {
  type        = string
  description = "Proxmox Token ID"
}

variable "pm_api_token_secret" {
  type        = string
  description = "Proxmox Token Secret"
  sensitive   = true
}

provider "proxmox" {
  pm_api_url      = var.pm_api_url
  pm_api_token_id = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure = true
}
