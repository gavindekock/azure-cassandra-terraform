variable "azure_region" {
  default = "East US 2"
}

variable "client_id" {
  default = "d9ad95b5-9a19-49ca-af76-e517b9b1b373"
}

variable "client_secret" {
  default = "567dd1e5-0d34-4808-a65a-effe752e5ee9"
}

variable "prefix" {
  default = "test-"
}

variable "subscription_id" {
  default = "1d3bc944-c31f-41a9-a1ac-cafea961eba5"
}

variable "ssh_keys" {
  type = "list"
  default = [{
    path     = "/home/ops/.ssh/authorized_keys"
    key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHeqz5mrAA5Y+ZkAp3ZX31gHi954JBNNZU8MUA65qkPEMZ8YF5+MfoMZBiB9YBsP2G6wkn/zWOZsS299613dZZzIjkRCsJV4jqem7SK1vGI8sEXIr4H1oThtpKmHfLvoF7xYggT2NWyBxHkAaQLaSNenrCKYjyaNGpq7sYDEJ2t9xth4yAbFOYcrxx/s7lD/hE3z5OHTFk/Lqm7nSSx9zahJEU1RxZ0+JZwtWTUfwxktmWfDGmlBzN9ZZs2Znv4Zm9mJqTfUIufQrwwgFb9FhqxLiXwE49yokAT2j9XfvDnnOMGUqVuY15m2RFIouo/HU9NsgdZDxmB/lrJCf8lH30uIUbRjxnXQ2sKA4Ba/NdqP9Rdtj/Mov4kUNnScUUf8iYMSpfCL0BDY/N9oCN86fBhiREZqVqFn7iwLbQTwRZ7Fmk0/UNGpWeVbqYSm17rLiqmIs02PMepGmb6Ok5o+habgI4nXqw3+5nB8yaTAwIQcn43S4+dLvsmbONNk/gxk7UvI8J3ZALStEVRimuy72aHuseBKLnWWsDo8M1p2eXvABE84IgVNrYklgodNP7GExxNLSLqcsZa9ZALc+P3FRjgYbLC/qMWtkzPH5TEHPU4P5KLbHr4ZN3kV2MiARTtjWOlYMnMnrGu6NYxCmjHsbZxfhhZ2rU3uIEvjUBo9rdtQ== timfpark@gmail.com"
  }]
}

variable "tenant_id" {
  default = "72f988bf-86f1-41af-91ab-2d7cd011db47"
}

variable "vm_count" {
  default = "1"
}

variable "vm_size" {
  default = "Standard_L8s"
}

variable "private_key_path" {
  default = "/Users/tpark/.ssh/id_rsa"
}
