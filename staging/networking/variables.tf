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

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "AWS region in which our architecture is being deployed"
}

variable "vpc_cidr" {
  default     = "10.200.0.0/16"
  type        = string
  description = "CIDR range of VPC for the dev environment"
}

# Public subnets in VPC
variable "public_subnet_cidrs" {
  default     = ["10.200.0.0/24", "10.200.1.0/24", "10.200.2.0/24"]
  type        = list(string)
  description = "Public Subnet CIDRs"
}

# Private subnets in VPC
variable "private_subnet_cidrs" {
  default     = ["10.200.3.0/24", "10.200.4.0/24", "10.200.5.0/24"]
  type        = list(string)
  description = "Private Subnet CIDRs"
}

