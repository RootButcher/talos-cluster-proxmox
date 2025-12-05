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