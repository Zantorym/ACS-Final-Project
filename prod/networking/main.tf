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
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-Pubic-Subnet-${count.index}"
    }
  )
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-Private-Subnet-${count.index}"
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
  subnet_id     = aws_subnet.public_subnet[1].id
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-NAT"
    }
  )
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-Public-Route-Table"
    }
  )
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-Private-Route-Table"
    }
  )
}

resource "aws_route_table_association" "public_route_table_association" {
  count          = length(aws_subnet.public_subnet[*].id)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = length(aws_subnet.private_subnet[*].id)
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet.*.id[count.index]
}