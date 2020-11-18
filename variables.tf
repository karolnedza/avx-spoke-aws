##############################################
# Variables 

variable "avtx_gw_ha" {default = false}
variable "hpe" {default = false}

variable "cloud_type" {}           

variable "cloud_region" {
    type = "map"
    
    default = {
        aws = "us-east-1"
        azure = "East US"
  }
}
    
variable "spoke_gw_name" {}           
variable "vnet_vpc_address_space" {}   
variable "transit_segment" {}        

variable "aviatrix_transit_gateway" {}      
variable "ctrl_password" {}
variable "vcs_repository" {default = "placeholder"}


# variable "public_key" {}
# variable "private_key" {}
variable "key_name" {default = "avtx-key"}


variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "azure_subscription_id" {}
variable "azure_directory_id" {}
variable "azure_application_id" {}
variable "azure_application_key" {}

variable "vm_name" {default = "aws-default-instance"}

