provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.env}-s3-acsgroup13"
    key    = "network/terraform.tfstate"
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
  name_prefix = "${var.acs_group}-${var.env}"
}

resource "aws_key_pair" "web_key" {
  key_name   = var.acs_group
  public_key = file("${var.acs_group}.pub")
}

resource "aws_instance" "amazon_server" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  security_groups             = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/user_data.sh")

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.acs_group}-Amazon-Linux"
    }
  )
}

resource "aws_launch_configuration" "launch_config" {
  name_prefix     = "lt-"
  image_id        = aws_instance.amazon_server.ami
  instance_type   = aws_instance.amazon_server.instance_type
  user_data       = aws_instance.amazon_server.user_data
  key_name        = aws_instance.amazon_server.key_name
  security_groups             = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "${aws_launch_configuration.launch_config.name}-asg"
  desired_capacity   = 1
  max_size           = 4
  min_size           = 1
  launch_configuration = aws_launch_configuration.launch_config.name
  vpc_zone_identifier  = [aws_instance.amazon_server.subnet_id]

}

resource "aws_security_group" "web_sg" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description      = "HTTP from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.acs_group}-sg"
    }
  )
}

