variable "cluster_name" {
  description = "name of talos cluster"
  type = string
}
variable "VIP" {
  description = "VIP IP address"
  type    = string
}
variable "talos_image_url" {
  description = "talos image factory"
  type    = string
  #default = "factory.talos.dev/nocloud-installer/5b7d2ab1fbe685e4e9a28d2d204049be045e1eae07973331aaf16b91824609c7:v1.11.5"
  default = "factory.talos.dev/nocloud-installer/d3dc673627e9b94c6cd4122289aa52c2484cddb31017ae21b75309846e257d30:v1.11.5"
}
variable "ip_config" {
  description = "Configuration for ip configuration"
  type = object({
    gateway = string
    CIDR = number
    DNS = optional(string)
    Vlan = optional(number)
  })
}
variable "controlplane_config"{
  description = "template yaml to apply to controlplane if not defined uses module local template"
  type = string
  default = null
}
variable "worker_config" {
  description = "template yaml to apply to worker if not defined uses module local template"
  type = string
  default = null
}
variable "controlplane_nodes"  {
  description = "map of the cp nodes"
  type = map(object({
    hostname= string
    ipAddress = string
    vmid = number
  }))
}
#variable "worker_nodes"  {
#  description = "map of the worker nodes"
#  type = map(object({
#    hostname= string
#    ipAddress = string
#    vmid = number
#    install_disk= string
#    image= string
# }))
#}
variable "vm-specs" {
  description = "basic vm config options"
  type = object({
    storage = object({
      size = number
      pool = string
    })
    cpu = object({
      cores = number
      #type = optional(string)
    })
    memory = object({
      size = number
    })
    install_disk = string
    target_node = string
  })
}
variable "bootstrap_iso" {
  type = string
  default = "local:iso/talos-amd64.iso"
}
variable "workers" {
  type = object({
    quantity = number
    name-prefix = string
    vmid-start = number
  })
}
locals {
  worker_config = coalesce(var.worker_config, "${path.module}/template/worker.yaml")
  controlplane_config = coalesce(var.controlplane_config, "${path.module}/template/controlplane.yaml")
}