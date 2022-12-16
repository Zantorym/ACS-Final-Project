variable "default_tags" {
  default = {
    "Owner" = "ACSGroup13"
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}

variable "prefix" {
  default     = "Group13"
  type        = string
  description = "Name of the group to be used as prefix"
}

variable "env" {
  default     = "prod"
  type        = string
  description = "Production Environment"
}

variable "public_subnet_cidrs" {
  default     = ["10.200.0.0/24", "10.200.1.0/24", "10.200.2.0/24"]
  type        = list(string)
  description = "Public subnet CIDRs"
}

variable "private_subnet_cidrs" {
  default     = ["10.200.3.0/24", "10.200.4.0/24", "10.200.5.0/24"]
  type        = list(string)
  description = "Private subnet CIDRs"
}