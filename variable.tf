variable "resource_group_name" {
  description = "resource_group_name"
  type        = string
  default     = "rg-vm-demo"
}
variable "location" {
  description = "Azure region"
  type        = string
  default     = "IndiaSouthCentral"
}
variable "prefix" {
  description = "Prefix used for naming all resources"
  type        = string
  default     = "wasd"
}
variable "vnet_address_space" {
  description = "Vnet address"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
variable "subnet_prefixes" {
  description = "Address for each subnet"
  type        = map(string)
  default = {
    "web"     = "10.0.1.0/24"
    "app"     = "10.0.2.0/24"
    "data"    = "10.0.3.0/24"
    "bastion" = "10.0.4.0/24"
  }
}
variable "vm_size" {
  description = "Size of our VM"
  type        = string
  default     = "Standard_B1s"
}
variable "ssh_public_key_path" {
  description = "Path to the SSH public key used for VM login."
  type        = string
  default     = "D:/Code/TF/azure_linux_vm.pub"
}

variable "my_ip" {
  description = "My personal IP"
  type        = string
  default     = "49.36.48.31/32"
}