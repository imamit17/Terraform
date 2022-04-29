variable "name" {
  description = "Name of the spoke virtual network."
}

variable "resource_group_name" {
  description = "Name of resource group to deploy resources in."
}

variable "location" {
  description = "The Azure Region in which to create resource."
}

variable "subnet_id" {
  description = "Id of the subnet to deploy Application Gateway."
}

variable "private_ip_address" {
  description = "The Private IP Address to use for the Application Gateway."
}

variable "capacity" {
  description = "Min and max capacity for auto scaling"
  type = object({
    min = number
    max = number
  })
  default = null
}


variable "zones" {
  description = "A collection of availability zones to spread the Application Gateway over."
  type        = list(string)
  default     = null
}




variable "ssl_policy_name" {
  description = "SSL Policy name"
  default     = "AppGwSslPolicy20170401"
}
