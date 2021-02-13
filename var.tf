variable location {
  default = "East US"
}

## Resource group variables ##
variable resource_group_name {
  default = "aksdemo-rg"
}


## AKS kubernetes cluster variables ##
variable cluster_name {
  default = "aksdemo1"
}

variable "agent_count" {
  default = 2
}

variable "dns_prefix" {
  default = "aksdemo"
}

variable "admin_username" {
    default = "demo"
}
