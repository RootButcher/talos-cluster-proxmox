terraform {
  required_providers {
    #TODO move to BGP better cloud-init support but sshs into proxmox
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc06" #telemate seems to never move
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0" #very outdated
    }
  }
}