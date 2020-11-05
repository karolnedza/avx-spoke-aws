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
  name                 = "avtx-spoke-${var.spoke_gw_name}-net"
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
  subnet       = (var.cloud_type == "aws") ? aviatrix_vpc.spoke_net[count.index].subnets[local.subnet_count].cidr : aviatrix_vpc.spoke_net[count.index].subnets[0].cidr
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
