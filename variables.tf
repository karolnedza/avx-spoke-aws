##############################################
# Variables 

variable "avtx_gw_ha" {default = false}
variable "hpe" {default = false}

variable "cloud_type" {}           

# variable "aws_cloud_region" {default = "us-east-1"}

# variable "azure_cloud_region" {default = "East US"}

#variable "spoke_gw_name" {}           
variable "vnet_vpc_address_space" {}   
variable "transit_segment" {}        

variable "aviatrix_transit_gateway" {}

variable "cloud_region" {
  type        = map(string)
  default     = {
    tg-eu-west-2-aws     = "eu-west-2",
    tg-eu-west-2-azure = "West Europe",
    tg-south-central-us-azure = "South Central US"
  }
}

# variable "cloud_type" {
#   type        = map(string)
#   default     = {
#     tg-eu-west-2-aws     = "aws",
#     tg-eu-west-2-azure = "azure",
#     tg-south-central-us-azure = "azure"
#   }
# }

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

variable "vm_name" {default = "default-name"}

