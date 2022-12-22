variable "default_tags" {
  default = {
    "Owner" = "ACSGroup13"
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}

variable "env" {
  default     = "dev"
  type        = string
  description = "Deployment environment"
}

variable "vpc_cidr" {
  default     = "10.100.0.0/16"
  type        = string
  description = "CIDR range of VPC for the dev environment"
}

# Public subnets in VPC
variable "public_subnet_cidrs" {
  default     = ["10.100.0.0/24", "10.100.1.0/24"]
  type        = list(string)
  description = "Public Subnet CIDRs"
}

# Private subnets in VPC
variable "private_subnet_cidrs" {
  default     = ["10.100.2.0/24", "10.100.3.0/24"]
  type        = list(string)
  description = "Private Subnet CIDRs"
}