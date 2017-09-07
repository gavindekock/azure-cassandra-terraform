provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

resource "azurerm_resource_group" "cassandra_rg" {
  name     = "${var.prefix}cassandra-rg"
  location = "${var.azure_region}"
}

resource "azurerm_availability_set" "cassandra_as" {
  name                = "${var.prefix}cassandra-rg"
  location            = "${var.azure_region}"
  managed             = true
  resource_group_name = "${azurerm_resource_group.cassandra_rg.name}"
}

resource "azurerm_network_security_group" "cassandra_nsg" {
  name                = "${var.prefix}cassandra-nsg"
  location            = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.cassandra_rg.name}"
}

resource "azurerm_network_security_rule" "cassandra_nsr_inbound" {
  name                        = "${var.prefix}cassandra-nsr-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.cassandra_rg.name}"
  network_security_group_name = "${azurerm_network_security_group.cassandra_nsg.name}"
}

resource "azurerm_network_security_rule" "cassandra_nsr_outbound" {
  name                        = "${var.prefix}cassandra-nsr-outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.cassandra_rg.name}"
  network_security_group_name = "${azurerm_network_security_group.cassandra_nsg.name}"
}

resource "azurerm_virtual_network" "cassandra_vnet" {
  name                = "${var.prefix}cassandra-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.cassandra_rg.name}"
}

resource "azurerm_subnet" "cassandra_subnet" {
  name                 = "${var.prefix}cassandra-subnet"
  resource_group_name  = "${azurerm_resource_group.cassandra_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.cassandra_vnet.name}"
  address_prefix       = "10.1.0.0/16"
}

resource "azurerm_network_interface" "cassandra_nics" {
  count               = "${var.vm_count}"
  name                = "${var.prefix}cassandra-nic-${count.index}"
  location            = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.cassandra_rg.name}"
  network_security_group_id = "${azurerm_network_security_group.cassandra_nsg.id}"

  ip_configuration {
    name                          = "${var.prefix}cassandra-ip-config-${count.index}"
    subnet_id                     = "${azurerm_subnet.cassandra_subnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.1.0.${10 + count.index}"
  }
}

resource "azurerm_public_ip" "bastion_public_ip" {
  name                         = "${var.prefix}bastion-public-ip"
  location                     = "${var.azure_region}"
  resource_group_name          = "${azurerm_resource_group.cassandra_rg.name}"
  public_ip_address_allocation = "dynamic"
}

resource "azurerm_network_interface" "bastion_nic" {
  name                = "${var.prefix}bastion-nic"
  location            = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.cassandra_rg.name}"
  network_security_group_id = "${azurerm_network_security_group.cassandra_nsg.id}"

  ip_configuration {
    name                          = "${var.prefix}cassandra-ip-config-${count.index}"
    subnet_id                     = "${azurerm_subnet.cassandra_subnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.1.0.9"
    public_ip_address_id          = "${azurerm_public_ip.bastion_public_ip.id}"
  }
}

resource "azurerm_virtual_machine" "bastion_vm" {
  name                  = "${var.prefix}cassandra-bastion"
  location              = "${var.azure_region}"
  resource_group_name   = "${azurerm_resource_group.cassandra_rg.name}"
  network_interface_ids = ["${azurerm_network_interface.bastion_nic.id}"]
  vm_size               = "Basic_A0"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  os_profile {
    computer_name  = "cassandra-bastion"
    admin_username = "ops"
    admin_password = "NOTSUPPORTED1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys = ["${var.ssh_keys}"]
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "cassandra-bastion-os-disk-1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
}

resource "azurerm_virtual_machine" "cassandra_vms" {
  count                 = "${var.vm_count}"
  name                  = "${var.prefix}cassandra-${count.index}"
  location              = "${var.azure_region}"
  resource_group_name   = "${azurerm_resource_group.cassandra_rg.name}"
  availability_set_id   = "${azurerm_availability_set.cassandra_as.id}"
  network_interface_ids = ["${element(azurerm_network_interface.cassandra_nics.*.id, count.index)}"]
  vm_size               = "${var.vm_size}"

  delete_os_disk_on_termination = true

  os_profile {
    computer_name  = "cassandra-${count.index}"
    admin_username = "ops"
    admin_password = "NOTSUPPORTED1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys = ["${var.ssh_keys}"]
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "cassandra-${count.index}-os-disk-1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
}

resource "null_resource" "install_cassandra" {
    depends_on = ["azurerm_virtual_machine.cassandra_vms", "azurerm_public_ip.bastion_public_ip"]
    count = "${var.vm_count}"

    connection {
        bastion_host = "${azurerm_public_ip.bastion_public_ip.ip_address}"
        host  = "10.1.0.${10 + count.index}"
        user  = "ops"
        private_key = "${file(var.private_key_path)}"
    }

    provisioner "file" {
        source = "provisioning/install-cassandra.sh"
        destination = "/home/ops/install-cassandra.sh"
    }

    provisioner "remote-exec" {
        inline = ["chmod +x /home/ops/install-cassandra.sh && /home/ops/install-cassandra.sh"]
    }
}
