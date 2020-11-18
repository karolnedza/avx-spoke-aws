####################################################################
# AWS Ubuntu Instance

resource "aws_instance" "test_instance" {
  count = (var.cloud_type == "aws") ? 1 : 0
  key_name   = aws_key_pair.key[0].key_name
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id   = aviatrix_vpc.aviatrix_vpc_vnet.subnets[local.subnet_count].subnet_id
  vpc_security_group_ids  = ["${aws_security_group.allow_ssh_icmp_spoke[0].id}"]
  associate_public_ip_address = true
    user_data = <<EOF
#!/bin/bash
# allow linuix access by password
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo echo 'ubuntu:Password123!' | sudo /usr/sbin/chpasswd
sudo /etc/init.d/ssh restart

EOF
  
  connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = self.public_ip
    private_key = var.private_key
  }

  tags = {
    #Name = "aws-test-instance"
     Name = var.vm_name
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "allow_ssh_icmp_spoke" {
  count = (var.cloud_type == "aws") ? 1 : 0
  name        = "allow_ssh_icmp"
  description = "Allow SSH & ICMP inbound traffic"
  vpc_id      = aviatrix_vpc.aviatrix_vpc_vnet.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
#

resource "aws_key_pair" "key" {
  count = (var.cloud_type == "aws") ? 1 : 0
  key_name   = "${var.vm_name}-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCnNDeCuEOgJjtFFzWa9fXyKj8mSdCnCVR+iOm40JYSO4/kKEOflq0VvtIcnezv1wa4Ghj3RqEcFd9857qAQfqsn5KgjwuoYG37eTthz9waKSbem6l8hilR4CncagBqMqje8EDuWFdyNPWmgM04nHJ+HRn0UoXzYikSbbQJ082XORREEpZA4Rt7ZHtIncqN5EMBPQ4lflDOR7l0pCTcGObHNPOuWje35ZQqcjryskUkgvEzx+kFxnJ5fG2cwvDkoq8JrCwXhZNmoYNvR6cAtzMo7S/v7THxCxYMgsSUWRzY1+Pi93EB/CIZp5le0gewblrzXpc8DmHd5NPi3ObPwPTh dennis@NUC"
}

# output "ec2_public_ip" {
# value = aws_instance.test_instance[0].public_ip

#}

####################################################################
# Azure Ubuntu Instance
resource "azurerm_resource_group" "aviatrix-rg" {
  count = (var.cloud_type == "azure") ? 1 : 0
  name     = "rg-${var.vm_name}"
  location = var.cloud_region
}

resource "azurerm_public_ip" "avtx-public-ip" {
  count = (var.cloud_type == "azure") ? 1 : 0
  name                = "public-ip-${var.vm_name}"
  location            = azurerm_resource_group.aviatrix-rg[0].location
  resource_group_name = azurerm_resource_group.aviatrix-rg[0].name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "iface" {
  count = (var.cloud_type == "azure") ? 1 : 0
  name                = "nic-${var.vm_name}"
  location            = azurerm_resource_group.aviatrix-rg[0].location
  resource_group_name = azurerm_resource_group.aviatrix-rg[0].name

  ip_configuration {
    name                          = "avtx_internal-${var.vm_name}"
    subnet_id     = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${split(":",aviatrix_vpc.aviatrix_vpc_vnet.vpc_id)[1]}/providers/Microsoft.Network/virtualNetworks/${split(":",aviatrix_vpc.aviatrix_vpc_vnet.vpc_id)[0]}/subnets/${aviatrix_vpc.aviatrix_vpc_vnet.subnets[0].subnet_id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.avtx-public-ip[0].id

  }
}

resource "azurerm_linux_virtual_machine" "azure-spoke-vm" {
  count = (var.cloud_type == "azure") ? 1 : 0
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.aviatrix-rg[0].name
  location            = azurerm_resource_group.aviatrix-rg[0].location
  size                = "Standard_B1s"
  admin_username      = "ubuntu"
  network_interface_ids = [
    azurerm_network_interface.iface[0].id,
  ]

  admin_password = "Aviatrix123#"
  disable_password_authentication = "false"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
