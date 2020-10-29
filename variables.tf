variable "example" {}            # This is CTRL Password
variable "pet_name_length" {}    # This can be used for ??


variable "gw_name" {}

variable "sec_domain_name" {}

variable "azure_account_name" {}

variable "avtx_transit_gw" {}

variable "azure_region" {}

variable "azure_cidr" {}

variable "avtx_gw_size" { default = "Standard_B1ms" }

variable "avtx_gw_ha" {default = false}

variable "hpe" { default = false}
