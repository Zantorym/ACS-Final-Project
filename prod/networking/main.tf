provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  public_cidrs = "10.200.0.0/16"
}

resource "aws_vpc" "main" {
  cidr_block       = local.public_cidrs
  instance_tenancy = "default"
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-VPC"
    }
  )
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidrs
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-Pubic-Subnet"
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-IGW"
    }
  )
}

resource "aws_eip" "eip" {
  vpc = true
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-ElasticIP"
    }
  )
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-NAT"
    }
  )
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-Route-Table"
    }
  )
}

resource "aws_route_table_association" "public_routes" {
  route_table_id = aws_route_table.route.id
  subnet_id      = aws_subnet.public_subnet.id
}

