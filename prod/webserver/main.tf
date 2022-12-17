provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "websrv_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "s3-final-prod"
    key    = "prod-networking/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}


locals {
  default_tags = merge(
    var.default_tags,
    { "env" = var.env }
  )
  Name = "${var.acs_group}-${var.env}"
}

resource "aws_key_pair" "web_key" {
  key_name   = var.acs_group
  public_key = file("${var.acs_group}.pub")
}

resource "aws_instance" "amazon_server" {
  ami                         = data.aws_ami.websrv_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.networking.outputs.public_subnet_ids[1]
  security_groups             = [aws_security_group.my_web_sg.id]
  associate_public_ip_address = true
  user_data                   = file("/home/ec2-user/environment/ACS-Final-Project/prod/webserver/user_data.sh")


  tags = merge(local.default_tags,
    {
      Name = "${var.acs_group}-Webser-VM"
    }
  )
}

#resource "aws_launch_template" "amazon_server" {
#  name_prefix            = "amazon_server-"
#  image_id               = data.aws_ami.websrv_amazon_linux.id
#  instance_type          = var.instance_type
#  vpc_security_group_ids = [aws_security_group.public_sg.id]
#  key_name               = aws_key_pair.web_key.key_name
#  user_data              = base64encode(file("/home/ec2-user/environment/ACS-Final-Project/prod/webserver/user_data.sh")
#
#  tags = merge(local.default_tags,
#    {
#      Name = "${var.acs_group}-Webser-VM-[count.index]"
#    }
#  )
#}