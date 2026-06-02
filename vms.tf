resource "proxmox_vm_qemu" "talos_CP_node" {
  for_each  = var.controlplane_nodes
  vmid      = each.value.vmid
  name      = each.key
  ipconfig0 = "ip=${each.value.ipAddress}/${var.ip_config.CIDR},gw=${var.ip_config.gateway}"


  boot            = "order=scsi0;ide0"
  machine         = "q35"
  bios            = "ovmf"
  os_type         = "cloud-init"
  scsihw          = "virtio-scsi-pci"
  agent           = 1
  additional_wait = 20
  target_node     = var.vm-specs.target_node
  memory          = var.vm-specs.memory.size

  tags = "tofu"
  #noinspection HCLUnknownBlockType
  startup_shutdown {
    order            = -1
    shutdown_timeout = -1
    startup_delay    = -1
  }

  #noinspection HCLUnknownBlockType
  disks {
    ide {
      ide0 {
        cdrom {
          iso = var.bootstrap_iso
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size    = "${var.vm-specs.storage.size}G"
          storage = var.vm-specs.storage.pool
        }
      }
      scsi1 {
        cloudinit {
          storage = var.vm-specs.storage.pool
        }
      }
      # Optional extra disk for Rook-Ceph (surfaces as /dev/sdb in Talos).
      dynamic "scsi2" {
        for_each = var.vm-specs.rook_disk != null ? [var.vm-specs.rook_disk] : []
        content {
          disk {
            size    = "${scsi2.value.size}G"
            storage = scsi2.value.pool
          }
        }
      }
    }
  }

  # CPU Configuration
  #noinspection HCLUnknownBlockType
  cpu {
    type  = "host"
    cores = var.vm-specs.cpu.cores
  }

  # Network Configuration

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }
  #noinspection HCLUnknownBlockType
  efidisk {
    efitype           = "2m"
    storage           = var.vm-specs.storage.pool
    pre_enrolled_keys = true
  }


}
resource "proxmox_vm_qemu" "talos_workers" {
  count     = var.workers.quantity
  vmid      = var.workers.vmid-start + count.index + 1
  name      = "${local.worker_name_prefix}-${count.index + 1}"
  ipconfig0 = "ip=dhcp"

  boot            = "order=scsi0;ide0"
  machine         = "q35"
  bios            = "ovmf"
  os_type         = "cloud-init"
  scsihw          = "virtio-scsi-pci"
  agent           = 1
  additional_wait = 20
  target_node     = var.vm-specs.target_node
  memory          = var.vm-specs.memory.size

  #added to prevent unnecessary state modifications
  tags = "tofu"
  #noinspection HCLUnknownBlockType
  startup_shutdown {
    order            = -1
    shutdown_timeout = -1
    startup_delay    = -1
  }

  #noinspection HCLUnknownBlockType
  disks {
    ide {
      ide0 {
        cdrom {
          iso = var.bootstrap_iso
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size    = "${var.vm-specs.storage.size}G"
          storage = var.vm-specs.storage.pool
        }
      }
      scsi1 {
        cloudinit {
          storage = var.vm-specs.storage.pool
        }
      }
      # Optional extra disk for Rook-Ceph (surfaces as /dev/sdb in Talos).
      dynamic "scsi2" {
        for_each = var.vm-specs.rook_disk != null ? [var.vm-specs.rook_disk] : []
        content {
          disk {
            size    = "${scsi2.value.size}G"
            storage = scsi2.value.pool
          }
        }
      }
    }
  }

  # CPU Configuration
  #noinspection HCLUnknownBlockType
  cpu {
    type  = "host"
    cores = var.vm-specs.cpu.cores
  }

  # Network Configuration

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }
  #noinspection HCLUnknownBlockType
  efidisk {
    efitype           = "2m"
    storage           = var.vm-specs.storage.pool
    pre_enrolled_keys = true
  }

  #noinspection HCLUnknownBlockType
  pcis {
    pci0 {
      mapping {
        mapping_id  = var.workers.pci
        pcie        = true
        primary_gpu = false
        rombar      = true
      }
    }
  }
}