

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.VIP}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  #talos_version      = var.talos_version
  #kubernetes_version = var.kubernetes_version
}
data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.VIP}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  #talos_version      = var.talos_version
  #kubernetes_version = var.kubernetes_version
}
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = concat([var.VIP], [for v in var.controlplane_nodes : v.ipAddress])
}
resource "talos_machine_configuration_apply" "controlplane" {
  depends_on                  = [proxmox_vm_qemu.talos_CP_node]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  for_each                    = var.controlplane_nodes
  node                        = each.value.ipAddress
  config_patches = [
    templatefile(local.controlplane_config, {
      hostname      = proxmox_vm_qemu.talos_CP_node[each.key].name
      ip_address    = "${each.value.ipAddress}/${var.ip_config.CIDR}"
      install_image = var.talos_image_url
      vip           = var.VIP

    })
  ]
}
resource "talos_machine_configuration_apply" "worker" {
  depends_on                  = [talos_machine_configuration_apply.controlplane, proxmox_vm_qemu.talos_workers]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  count                       = var.workers.quantity
  node                        = proxmox_vm_qemu.talos_workers[count.index].default_ipv4_address
  config_patches = [
    templatefile(local.worker_config, {
      hostname = proxmox_vm_qemu.talos_workers[count.index].name
      #ip_address = "${proxmox_vm_qemu.talos_workers[count.index].default_ipv4_address}/${var.ip_config.CIDR}"
      install_image = var.talos_image_url
    })
  ]
}
resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = [for v in var.controlplane_nodes : v.ipAddress][0]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = [for k, v in var.controlplane_nodes : v.ipAddress][0]
  endpoint             = var.VIP
}