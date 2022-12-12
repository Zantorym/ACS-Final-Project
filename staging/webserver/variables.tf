variable "default_tags" {
  default = {
    "Owner" = "ACSGroup13"
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}

variable "acs_group" {
  default     = "Group13"
  type        = string
  description = "Name of the group to be used as prefix"
}

variable "env" {
  default     = "staging"
  type        = string
  description = "Staging Environment"
}

variable "instance_type" {
  default = "t3.small"
  type    = string 
  description = "Type of the instance"
}
