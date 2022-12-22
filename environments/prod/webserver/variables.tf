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
  default     = "prod"
  type        = string
  description = "Production Environment"
}

variable "instance_type" {
  default     = "t3.medium"
  type        = string
  description = "Type of the instance"
}

variable "tg_protocol" {
  default     = "HTTP"
  type        = string
  description = "Target group protocol"
}

variable "tg_port" {
  default     = 80
  type        = number
  description = "Target gropu port"
}

variable "listener_protocol" {
  default     = "HTTP"
  type        = string
  description = "listener protocol"
}

variable "listener_port" {
  default     = 80
  type        = number
  description = "Listener port"
}