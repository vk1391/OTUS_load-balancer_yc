# variable "folder_id" {
#   type = string
# }

variable "vpc_name" {
  type = string
  description = "VPC name"
}

variable "zone1" {
  type = string
  description = "zone"
}
variable "zone2" {
  type = string
  description = "zone"
}
variable "subnet_name1" {
  type = string
  description = "subnet name"
}
variable "subnet_name2" {
  type = string
  description = "subnet name"
}
variable "pub_subnet_name1" {
  type = string
  description = "subnet name"
}
variable "pub_subnet_name2" {
  type = string
  description = "subnet name"
}
variable "subnet_cidrs1" {
  type = list(string)
  description = "CIDRs"
}
variable "subnet_cidrs2" {
  type = list(string)
  description = "CIDRs"
}
variable "pub_subnet_cidrs1" {
  type = list(string)
  description = "CIDRs"
}
variable "pub_subnet_cidrs2" {
  type = list(string)
  description = "CIDRs"
}
## VM parameters
variable "vm_name" {
  description = "VM name"
  type        = string
}
variable "vm_name2" {
  description = "VM name"
  type        = string
}
variable "vm_name3" {
  description = "VM name"
  type        = string
}
variable "vm_name4" {
  description = "VM name"
  type        = string
}
variable "vm_name5" {
  description = "VM name"
  type        = string
}
variable "vm_name6" {
  description = "VM name"
  type        = string
}
variable "vm_name7" {
  description = "VM name"
  type        = string
}

variable "cpu" {
  description = "VM CPU count"
  default     = 2
  type        = number
}

variable "memory" {
  description = "VM RAM size"
  default     = 4
  type        = number
}

variable "core_fraction" {
  description = "Core fraction, default 100%"
  default     = 100
  type        = number
}

variable "disk" {
  description = "VM Disk size"
  default     = 10
  type        = number
}

variable "image_id" {
  description = "Default image ID Ubuntu 20"
  default     = "fd8i5298136bt9mrprke" # Centos7
  type        = string
}

variable "nat" {
  type    = bool
  default = true
}

variable "platform_id" {
  type    = string
  default = "standard-v3"
}

variable "internal_ip_address" {
  type    = string
  default = null
}

variable "nat_ip_address" {
  type    = string
  default = null
}

variable "disk_type" {
  description = "Disk type"
  type        = string
  default     = "network-ssd"
}