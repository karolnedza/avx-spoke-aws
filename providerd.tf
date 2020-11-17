########## Providers

provider "aviatrix" {
  username     = "admin"
  password      = var.ctrl_password
  controller_ip = "18.157.190.93"
  version       = "2.17.0"
}
