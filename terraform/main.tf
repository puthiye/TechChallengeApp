provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_default_vpc" "default" {
}

resource "aws_default_subnet" "default" {
  availability_zone = "ap-southeast-2a"
  tags = {
    Name = "Default subnet"
  }
}

resource "aws_launch_configuration" "launch-config-sample" {
  image_id          = "ami-0810abbfb78d37cdf"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.elb-sg-sample.id]
  key_name = "key0"
   
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "elb-sg-sample" {
  name = "elb-sg-demo"
  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound SSH from any ip
  ingress {
    from_port   = var.elb_port
    to_port     = var.elb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "asg-sample" {
  launch_configuration = aws_launch_configuration.launch-config-sample.id
  vpc_zone_identifier  = [aws_default_subnet.default.id] 
  min_size = 1
  max_size = 2
  desired_capacity = 1

  load_balancers    = [aws_elb.elb-sample.name]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "demo-asg"
    propagate_at_launch = true
  }
}

resource "aws_elb" "elb-sample" {
  name               = "elb-demo"
  security_groups    = [aws_security_group.elb-sg-sample.id]
  subnets            = [aws_default_subnet.default.id]
  
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:22"
    interval            = 15
  }

  # Adding a listener for SSH 
  listener {
    lb_port           = var.elb_port
    instance_port     = var.elb_port
    instance_protocol = "tcp"
    lb_protocol       = "tcp"
  }

}
