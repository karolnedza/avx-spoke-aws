provider "aviatrix" {
  username     = "admin"
  password      = var.ctrl_password
  controller_ip = "18.156.141.82"
  version       = "2.17.0"
}


provider "aws" {
  version    = "~> 2.0"
 # region     = var.aws_cloud_region
  region =  var.cloud_region["${var.aviatrix_transit_gateway}"]
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
