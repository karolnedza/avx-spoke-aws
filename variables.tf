variable "cloud_type" {}           
variable "cloud_region" {}
variable "spoke_gw_name" {}           
variable "vnet_vpc_address_space" {}   
variable "transit_segment" {}        
variable "cloud_account_name" {} 
variable "aviatrix_transit_gateway" {}      


variable "avtx_gw_ha" {default = false}
variable "hpe" { default = false}
variable "ctrl_password" {}
variable "vcs_repository" {}

