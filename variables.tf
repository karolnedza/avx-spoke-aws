##############################################
# Variables 

variable "avtx_gw_ha" {default = false}
variable "hpe" {default = false}          
variable "vnet_vpc_address_space" {}   
variable "transit_segment" {}        

variable "aviatrix_transit_gateway" {}

variable "cloud_region" {
  type        = map(string)
  default     = {
    tg-eu-west-2     = "eu-west-2",
    tg-ap-southeast-1 = "ap-southeast-1",
    tg-south-central-us = "South Central US",
    tg-west-europe = "West Europe"
  }
 }

variable "ami_windows" {
  type        = map(string)
  default     = {
    tg-eu-west-2     = "ami-043e7c628e7e44707",
    tg-ap-southeast-1 = "ami-02ea9e3a06231daba"
  }
 }


variable "ctrl_password" {}
variable "vcs_repository" {default = "placeholder"}
variable "key_name" {default = "avtx-key"}


variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "azure_subscription_id" {}
variable "azure_directory_id" {}
variable "azure_application_id" {}
variable "azure_application_key" {}

variable "vm_name" {default = "default-name"}

