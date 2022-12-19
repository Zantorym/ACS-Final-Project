resource "aws_lb" "my_lb" {
  name               = "my-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_web_sg.id]
  subnets            = data.terraform_remote_state.network.outputs.public_subnet_ids[*]
  # depends_on = [
  #   aws_autoscaling_group.amazon_server_asg
  # ]
}

resource "aws_lb_target_group" "my_tg" {
  name     = "my-lb-tg-${substr(uuid(), 0, 3)}"
  protocol = var.tg_protocol
  port     = var.tg_port
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_lb_listener" "my_lb_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_tg.arn
  }
}