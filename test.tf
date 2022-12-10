

#----------------------------------------------------------
# ACS730 - Week 3 - Terraform Introduction
#
# Build EC2 Instances
#
#----------------------------------------------------------

# Step 1 - Define the provider
provider "aws" {
  region = "us-east-1"
}

# Step 4 -  Attach EBS volume
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.week3.id
  instance_id = aws_instance.my_amazon.id
}


# Step 1,2 - Deploy EC2 instance in the default VPC
resource "aws_instance" "my_amazon" {
  ami           = "ami-08e4e35cccc6189f4"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.week3.key_name

  tags = {
    "Name"  = "Week3-Amazon-Linux"
    "Owner" = "Irina"
    "App"   = "Web"
  }
}

# Step 4 - Create another EBS volume
resource "aws_ebs_volume" "week3" {
  availability_zone = "us-east-1b"
  size              = 40

  tags = {
    Name = "Week3"
  }
}

# Step 5 - Adding SSH key to Amazon EC2
resource "aws_key_pair" "week3" {
  key_name   = "week3"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1KwXoT0GEl2+o4l5AGglfyIBkaljiQdzyOuCfoKlSDS772H+LjAsO1MUBpBdFG43caaiZ5IHhYbsElW+dByPXcK7DDeWhuL+cLxGELut3PUwwhD5Swl6naNhAmpkiYjSk2eqFWRpI3ppN4OOx/0yEjWLGLgOG93Um/pgVzqjaQNPuc5Ji9mc8xfDoI8A88NQkDEcWbwR39RdoF6Tdq3NzRBJExT380v3M5rPDhRK9IgRJ1Ug7zV6fR9bqULs+NIZYKOBUPRKWKfrkpbPQh3So/cld56KtkQaox6ywHRZkeVPRARo2nbt1kazBhcPKxuED68zehUpiq/gJaxqByxth ec2-user@ip-172-31-41-148.ec2.internal"
}