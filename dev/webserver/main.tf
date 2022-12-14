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

data "template_file" "test" {
  template = file("${path.module}/user_data.sh")
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

resource "aws_launch_template" "my_bastion" {
  name_prefix            = "my_bastion"
  image_id               = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.my_public_sg.id]
  key_name               = aws_key_pair.web_key.key_name

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.acs_group}-Bastion"

    }
  )
}

resource "aws_autoscaling_group" "my_bastion" {
  name                = "my_bastion"
  vpc_zone_identifier = tolist(data.terraform_remote_state.network.outputs.public_subnet_ids)
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.my_bastion.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "amazon_server" {
  name_prefix            = "amazon_server-"
  image_id               = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.my_private_sg.id]
  key_name               = aws_key_pair.web_key.key_name
  user_data              = base64encode(data.template_file.test.rendered)

  tags = {
    Name = "amazon_server"
  }
}

resource "aws_autoscaling_group" "amazon_server_asg" {
  name                = "amazon_server"
  vpc_zone_identifier = tolist(data.terraform_remote_state.network.outputs.private_subnet_ids)
  min_size            = 1
  max_size            = 4
  desired_capacity    = 1

  target_group_arns = [aws_lb_target_group.my_tg.arn]
  launch_template {
    id      = aws_launch_template.amazon_server.id
    version = "$Latest"
  }
}

# resource "aws_autoscaling_attachment" "asg_attachment_bar" {
#   autoscaling_group_name = aws_autoscaling_group.amazon_server_asg.id
#   # elb                    = var.elb
#   lb_target_group_arn = aws_lb_target_group.my_tg.arn
# }