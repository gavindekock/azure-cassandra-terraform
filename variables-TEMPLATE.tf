variable "azure_region" {
  default = "East US 2"
}

variable "client_id" {
  default = "<CLIENT ID>"
}

variable "client_secret" {
  default = "<CLIENT SECRET>"
}

variable "prefix" {
  default = "mycluster-"
}

variable "subscription_id" {
  default = "<SUBSCRIPTION ID>"
}

variable "ssh_keys" {
  type = "list"
  default = [{
    path     = "/home/ops/.ssh/authorized_keys"
    key_data = "<PUBLIC SSH KEY STRING>"
  }]
}

variable "tenant_id" {
  default = "<TENANT ID>"
}

variable "vm_count" {
  default = "6"
}

variable "vm_size" {
  default = "Standard_L8s"
}

variable "private_key_path" {
  default = "<YOUR PRIVATE SSH KEY PATH>"
}
