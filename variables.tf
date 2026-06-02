variable "cluster_name" {
  description = "name of talos cluster"
  type        = string
}
variable "VIP" {
  description = "VIP IP address"
  type        = string
}
variable "talos_version" {
  # WARNING: Tofu cannot upgrade Talos on running nodes.
  # Changing this value (or var.talos_extensions) only rewrites machine.install.image
  # in the on-node machine config — it does NOT trigger a Talos reinstall, and rebooting
  # the node does NOT pick up the new image (Talos boots the A/B partition, not the URL).
  # To roll the new image onto a live cluster, run `talosctl upgrade --image=<new-url>`
  # per node (workers in parallel, CP serially with etcd checks between).
  # A `tofu destroy` + `tofu apply` rebuild also picks up the new image — that's the only
  # path Tofu alone can take you down.
  description = "Talos version baked into the installer schematic (e.g. v1.11.5). See WARNING in this file: Tofu cannot upgrade running nodes; use talosctl upgrade or destroy+apply."
  type        = string
}
variable "talos_extensions" {
  # WARNING: silent fail. Unknown names are silently dropped by the factory data source filter
  # (talos_image_factory_extensions_versions) — they do NOT error at plan time. Verify the
  # rendered schematic body in `tofu plan` includes every extension you listed before applying.
  description = "Talos system extensions to bake into the installer image. Short names (e.g. \"iscsi-tools\"), looked up against the image factory catalog for var.talos_version. Names that don't match the catalog are silently dropped."
  type        = list(string)
}
variable "ip_config" {
  description = "Configuration for ip configuration"
  type = object({
    gateway = string
    CIDR    = optional(number, 24)
    DNS     = optional(string)
    Vlan    = optional(number) #TODO implement
  })
}
variable "controlplane_config" {
  description = "template yaml to apply to controlplane if not defined uses module local template"
  type        = string
  default     = null
}
variable "worker_config" {
  description = "template yaml to apply to worker if not defined uses module local template"
  type        = string
  default     = null
}
variable "controlplane_nodes" {
  description = "map of the cp nodes"
  type = map(object({
    ipAddress = string
    vmid      = number
  }))
}
variable "vm-specs" {
  description = "basic vm config options"
  type = object({
    storage = object({
      size = number
      pool = string
    })
    cpu = object({
      cores = optional(number, 4)
      type  = optional(string, "host")
    })
    memory = object({
      size = optional(number, 4096)
    })
    install_disk = optional(string, "/dev/sda")
    target_node  = string
    # Optional extra disk added as scsi2 on every node. Surfaces as /dev/sdb in Talos.
    # Used by Rook-Ceph (deviceFilter: ^sdb$). Omit to skip.
    rook_disk = optional(object({
      size = number # GB
      pool = string
    }))
  })
}
variable "bootstrap_iso" {
  type    = string
  default = "local:iso/talos-amd64.iso"
}
variable "workers" {
  type = object({
    quantity    = number
    name-prefix = optional(string)
    vmid-start  = number
    pci         = string
  })
}
locals {
  worker_config       = coalesce(var.worker_config, "${path.module}/template/worker.yaml")
  controlplane_config = coalesce(var.controlplane_config, "${path.module}/template/controlplane.yaml")

  worker_name_prefix = coalesce(var.workers.name-prefix, "${var.cluster_name}-worker")
}