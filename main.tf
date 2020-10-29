########## Provider 
provider "aviatrix" {
  username     = "admin"
  password      = var.example
  controller_ip = "35.171.31.227"
  version       = "2.17.0"
}


#######################################################################
# Azure Vnet
#
resource "aviatrix_vpc" "azure_vnet" {
  cloud_type           = 8
  account_name         = var.azure_account_name
  region               = var.azure_region
  name                 = "avtx-spoke-azure-${replace(lower(var.azure_region), " ", "-")}"
  cidr                 = var.azure_cidr
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
}

####################################################################
# Aviatrix Spoke GW

resource "aviatrix_spoke_gateway" "azure-spoke-gw" {
  cloud_type             = 8
  vpc_reg                = var.azure_region
  vpc_id                 = aviatrix_vpc.azure_vnet.vpc_id
  account_name           = var.azure_account_name
  gw_name                = var.gw_name
  insane_mode            = var.hpe
  gw_size                = var.hpe ? "Standard_D3_v2" : var.avtx_gw_size
  ha_gw_size             = var.avtx_gw_ha ? (var.hpe ? "Standard_D3_v2" : var.avtx_gw_size) : null # min "Standard_D3_v2" for HPE
  subnet                 = aviatrix_vpc.azure_vnet.subnets[0].cidr
  ha_subnet              = var.avtx_gw_ha ? aviatrix_vpc.azure_vnet.subnets[1].cidr : null
  enable_active_mesh     = true
  manage_transit_gateway_attachment = false
}

#####################################################################
# Spoke to Transit Attachment

resource "aviatrix_spoke_transit_attachment" "spoke_transit_attachment" {
  spoke_gw_name   = aviatrix_spoke_gateway.azure-spoke-gw.gw_name
  transit_gw_name = var.avtx_transit_gw
}

#######################################################################
# Spoke to Domain Association

resource "aviatrix_segmentation_security_domain_association" "east_segmentation_security_domain_association" {
  transit_gateway_name = var.avtx_transit_gw
  security_domain_name = var.sec_domain_name
  attachment_name      = aviatrix_spoke_transit_attachment.spoke_transit_attachment.spoke_gw_name

}
