# Default tags
variable "default_tags" {
  default = {
    "Owner" = "ACSGroup13"
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}

# Variable to signal the current environment 
variable "env" {
  default     = "dev"
  type        = string
  description = "Deployment Environment"
}

variable "project_name" {
  type        = string
  default     = "ACSFinalProject"
  description = "Name of the project to be used as prefix"
}