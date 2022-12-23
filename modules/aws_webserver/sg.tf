resource "aws_security_group" "publicSG" {
  name        = "${local.name_prefix}-Public-Security-Group"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
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
  
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-Public-Security-Group"
    }
  )
}

resource "aws_security_group" "privateSG" {
  name        = "${local.name_prefix}-Private-Security-Group"
  description = "Allow SSH inbound traffic from Bastion Host"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.publicSG.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.webSG.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-Private-Security-Group"
    }
  )
}

resource "aws_security_group" "webSG" {
  name        = "${local.name_prefix}-Web-Security-Group"
  description = "Allow all inbound HTTP traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    local.default_tags, {
      Name = "${local.name_prefix}-Web-Security-Group"
    }
  )
}
