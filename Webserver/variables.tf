# Instance type
variable "instance_type" {
  default = {
    "dev"    = "t3.micro"
    "staging" = "t3.small"
    "prod"    = "t3.medium"
  }
  description = "Type of the instance"
  type        = map(string)
}

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