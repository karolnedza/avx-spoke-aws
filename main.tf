#######################################################################
# VPC/Vnet
#
locals {
  subnet_count = length(aviatrix_vpc.aviatrix_vpc_vnet.subnets[*].cidr)/2
}


resource "aviatrix_vpc" "aviatrix_vpc_vnet" {
  cloud_type           =  1
  account_name         = "aws-account" 
  region               =  var.cloud_region["${var.aviatrix_transit_gateway}"]
  name                 = "${var.vm_name}-vpc"
  cidr                 = var.vnet_vpc_address_space
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
}

####################################################################
# Aviatrix Spoke GW

resource "aviatrix_spoke_gateway" "avx-spoke-gw" {
  cloud_type             =  1 
  vpc_reg               =  var.cloud_region["${var.aviatrix_transit_gateway}"]
  vpc_id                 = aviatrix_vpc.aviatrix_vpc_vnet.vpc_id
  account_name           =  "aws-account"
  gw_name                = "avx-${var.vm_name}-gw"
  insane_mode            = var.hpe
  gw_size                = "t2.medium" 
  subnet       = aviatrix_vpc.aviatrix_vpc_vnet.subnets[local.subnet_count].cidr
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



