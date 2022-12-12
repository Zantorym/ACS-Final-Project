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
    cidr_block = local.cidr_block
    instance_tenancy = "default"
    tags = merge (
        var.default_tags, {
            Name = "${var.prefix}-VPC"
        }
    )
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = local.public_cidrs
}
