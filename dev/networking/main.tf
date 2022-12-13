# Provider
provider "aws" {
    region = var.region
}

# List of all available availability zones
data "aws_availability_zones" "available" {
    state = "available"
}

# Local variables
locals {
  default_tags = merge(
    var.default_tags,
    { "env" = var.env }
  )
  name_prefix = "${var.acs_group}-${var.env}"
}

# VPC in which our architecture will be deployed
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    instance_tenancy = "default"
    tags = merge (
        var.default_tags, {
            Name = "${name_prefix}-VPC"
        }
    )
}

# Public subnets
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-Public-Subnet-${count.index}"
    }
  )
}

# Private subnets
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-Private-Subnet-${count.index}"
    }
  )
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-IGW"
    }
  )
}