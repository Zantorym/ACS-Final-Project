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

variable "private_cidrs" {
  default     = "10.200.0.0/24"
  type        = string
  description = "Private subnet CIDRs"
}