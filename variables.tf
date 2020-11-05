variable "cloud_type" {default = null}           
variable "cloud_region" {default = null}
variable "spoke_gw_name" {default = null}           
variable "vnet_vpc_address_space" {  default = null}   
variable "transit_segment" {default = null}        
#variable "cloud_account_name" {} 
variable "aviatrix_transit_gateway" {default = null}      


variable "avtx_gw_ha" {default = false}
variable "hpe" {default = false}
variable "ctrl_password" {default = null}
variable "vcs_repository" {default = null}

