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


resource "aws_launch_template" "amazon_server" {
  name_prefix            = "amazon_server-"
  image_id               = data.aws_ami.websrv_amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name               = aws_key_pair.web_key.key_name
  user_data              = base64encode(file("/home/ec2-user/environment/ACS-Final-Project/prod/webserver/user_data.sh"))

  tags = merge(local.default_tags,
    {
      Name = "${var.acs_group}-Webser-VM"
    }
  )
}

resource "aws_instance" "my_bastion" {
  ami                         = data.aws_ami.websrv_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.networking.outputs.public_subnet_ids[0]
  security_groups             = [aws_security_group.public_sg.id]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${var.acs_group}-Bastion"

    }
  )
}

resource "aws_autoscaling_group" "websrv_asg" {
  name                = "amazon-server"
  vpc_zone_identifier = tolist(data.terraform_remote_state.networking.outputs.private_subnet_ids)
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1

  target_group_arns = [aws_lb_target_group.my_tg.arn]
  launch_template {
    id      = aws_launch_template.amazon_server.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out-policy"
  autoscaling_group_name = aws_autoscaling_group.websrv_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
}

resource "aws_cloudwatch_metric_alarm" "scale_out" {
  alarm_name          = "scale-out-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  threshold           = "10"
  period              = "60"
  alarm_description   = "This alarm will trigger the scale-out policy if the average CPU utilization crosses 10% for 60 seconds"
  alarm_actions       = ["${aws_autoscaling_policy.scale_out.arn}"]
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in-policy"
  autoscaling_group_name = aws_autoscaling_group.websrv_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
}

resource "aws_cloudwatch_metric_alarm" "scale_in" {
  alarm_name          = "scale-in-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  threshold           = "5"
  period              = "60"
  alarm_description   = "This alarm will trigger the scale-in policy if the average CPU utilization is less than 5% for 60 seconds"
  alarm_actions       = ["${aws_autoscaling_policy.scale_in.arn}"]
}