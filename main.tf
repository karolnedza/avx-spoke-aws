########## Provider 
provider "aviatrix" {
  username     = "admin"
  password      = var.ctrl_password
  controller_ip = "18.157.190.93"
  version       = "2.17.0"
}


#######################################################################
# VPC/Vnet
#
locals {
  subnet_count = length(aviatrix_vpc.aviatrix_vpc_vnet.subnets[*].cidr)/2
}


resource "aviatrix_vpc" "aviatrix_vpc_vnet" {
  cloud_type           = (var.cloud_type == "aws") ? 1 : 8
  account_name         = (var.cloud_type == "aws") ? "aws-account" : "azure-account"
  region               = var.cloud_region
  name                 = "${var.spoke_gw_name}-vpc"
  cidr                 = var.vnet_vpc_address_space
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
}

####################################################################
# Aviatrix Spoke GW

resource "aviatrix_spoke_gateway" "avx-spoke-gw" {
  cloud_type             = (var.cloud_type == "aws") ? 1 : 8
  vpc_reg                = var.cloud_region
  vpc_id                 = aviatrix_vpc.aviatrix_vpc_vnet.vpc_id
  account_name           = (var.cloud_type == "aws") ? "aws-account" : "azure-account"
  gw_name                = var.spoke_gw_name
  insane_mode            = var.hpe
  gw_size                = (var.cloud_type == "aws") ? "t2.medium" : "Standard_B1ms"
  subnet       = (var.cloud_type == "aws") ? aviatrix_vpc.aviatrix_vpc_vnet.subnets[local.subnet_count].cidr : aviatrix_vpc.aviatrix_vpc_vnet.subnets[0].cidr
  enable_active_mesh     = true
  manage_transit_gateway_attachment = false
}

#####################################################################
# Spoke to Transit Attachment

resource "aviatrix_spoke_transit_attachment" "spoke_transit_attachment" {
  spoke_gw_name   = aviatrix_spoke_gateway.avx-spoke-gw.gw_name
  transit_gw_name = var.aviatrix_transit_gateway
}

#######################################################################
# Spoke to Domain Association

resource "aviatrix_segmentation_security_domain_association" "segmentation_security_domain_association" {
  transit_gateway_name = var.aviatrix_transit_gateway
  security_domain_name = var.transit_segment
  attachment_name      = aviatrix_spoke_transit_attachment.spoke_transit_attachment.spoke_gw_name

}

#### Resource EC2 

resource "aws_instance" "test_instance" {
  count = (var.cloud_type == "aws") ? 1 : 0
  key_name      = aws_key_pair.comp_generated_key.key_name
  ami           = data.aws_ami.ubuntu_server.id
  instance_type = "t2.micro"
  subnet_id   = aviatrix_vpc.aviatrix_vpc_vnet.subnets[local.subnet_count].subnet_id
  vpc_security_group_ids  = ["${aws_security_group.allow_ssh_icmp_spoke.id}"]
  associate_public_ip_address = true
  connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = self.public_ip
    private_key = var.private_key
#    private_key = file("avtx_priv_key.pem")
  }

  tags = {
    Name = "aws-test-instance"
   # Name = var.vm_name
  }
}


data "aws_ami" "ubuntu_server" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["*ubuntu-xenial-16.04-amd64-server-20181114*"]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "allow_ssh_icmp_spoke" {
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

resource "aws_key_pair" "comp_generated_key" {
  key_name   = "${var.key_name}_${var.aws_region}_vpc"
  public_key = var.public_key
}


