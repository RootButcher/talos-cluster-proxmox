module "talos_cluster" {
  source = "github.com/RootButcher/talos-cluster-proxmox.git"

  cluster_name = "HA-cluster"
  VIP = "10.0.11.200"
  ip_config = {
    gateway = "10.0.11.1"
    CIDR = 24
  }
  controlplane_nodes = {
    Cordova = {
      hostname = "cordova"
      ipAddress = "10.0.11.201"
      vmid = 201
    }
    Kenai = {
      hostname = "kenai"
      ipAddress = "10.0.11.202"
      vmid = 202
    }
    Soldotna = {
      hostname = "soldotna"
      ipAddress = "10.0.11.203"
      vmid = 203
    }
  }
  workers = {
    quantity = 2
    vmid-start = 500
  }

  vm-specs = {
    storage = {
      size = 20
      pool = "local-zfs"
    }
    cpu = {
      cores = 4
    }
    memory = {
      size = 4096
    }
    install_disk = "/dev/sda"
    target_node = "pve"
  }
}
resource "local_file" "kube_config" {
  filename = "out/kubeconfig.yaml"
  content  = module.talos_cluster.kubeconfig
}
resource "local_file" "talos_config" {
  filename = "out/talosconfig.yaml"
  content  = module.talos_cluster.talosconfig
}

