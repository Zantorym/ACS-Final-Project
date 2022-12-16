provider "aws" {
    region = "us-east-1"
}

data "aws_ami" "websrv-amazon-linux" {
    owners = ["amazon"]
    most_recent = true
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}   

data "terraform_remote_state" "networking" {
    backend = "s3"
    config = {
        bucket = "s3-final-prod"
        key = "prod-networking/terraform.tfstate"
        region = "us-east-1"
    }
}

