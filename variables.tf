variable "example" {}            # This is CTRL Password
variable "pet_name_length" {}    # This can be used for ??


variable "gw_name" {}           # must be variable 
variable "sec_domain_name" {}   # must be variable 
variable "azure_cidr" {}        # must be variable 
variable "azure_region" {}      # must be variable 


variable "azure_account_name" {}  # probably a variable 
variable "avtx_transit_gw" {}     # probably a variable 
variable "azure_region" {}        # probably a variable 


variable "avtx_gw_size" { default = "Standard_B1ms" }

variable "avtx_gw_ha" {default = false}

variable "hpe" { default = false}
