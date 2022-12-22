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
    key    = "${var.env}-network/terraform.tfstate"
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
  public_key = file("${var.acs_group}.pub") # The key should be stored in the webserver folder of the deployment environment
}

resource "aws_instance" "my_bastion" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  security_groups             = [aws_security_group.my_public_sg.id]
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

resource "aws_launch_template" "amazon_server" {
  name_prefix            = "amazon_server-"
  image_id               = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.my_private_sg.id]
  key_name               = aws_key_pair.web_key.key_name
  iam_instance_profile {
    name = "LabInstanceProfile"
  }
  user_data = base64encode(file("${path.module}/user_data.sh.tpl"))

  tags = {
    Name = "amazon_server"
  }
}

resource "aws_autoscaling_group" "amazon_server_asg" {
  name                = "amazon_server"
  vpc_zone_identifier = tolist(data.terraform_remote_state.network.outputs.private_subnet_ids)
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity

  target_group_arns = [aws_lb_target_group.my_tg.arn]
  launch_template {
    id      = aws_launch_template.amazon_server.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out-policy"
  autoscaling_group_name = aws_autoscaling_group.amazon_server_asg.name
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
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.amazon_server_asg.name
  }
  alarm_description = "This alarm will trigger the scale-out policy if the average CPU utilization crosses 10% for 60 seconds"
  alarm_actions     = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in-policy"
  autoscaling_group_name = aws_autoscaling_group.amazon_server_asg.name
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
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.amazon_server_asg.name
  }
  alarm_description = "This alarm will trigger the scale-in policy if the average CPU utilization is less than 5% for 60 seconds"
  alarm_actions     = [aws_autoscaling_policy.scale_in.arn]
}