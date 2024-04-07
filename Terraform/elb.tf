resource "aws_lb_target_group" "traccarALBTG" {
  target_type     = "instance"
  name            = "Traccar-ALB-TG"
  port            = 80
  protocol        = "HTTP"
  ip_address_type = "ipv4"
  vpc_id          = aws_vpc.traccarVPC.id
  health_check {
    protocol = "HTTP"
    path     = "/"
  }
}

resource "aws_lb_target_group_attachment" "traccarALBTGA" {
  count = 2
  target_group_arn = aws_lb_target_group.traccarALBTG.arn
  target_id        = aws_instance.traccarEC2[count.index].id
  port             = 80
}

resource "aws_security_group" "albSG" {
  name   = "ALB-SG"
  vpc_id = aws_vpc.traccarVPC.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_80_traffic" {
  security_group_id = aws_security_group.albSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_ALB_traffic_ipv4" {
  security_group_id = aws_security_group.traccarSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_lb" "traccarALB" {
  name               = "Traccar-ALB"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.albSG.id]
  subnets            = [aws_subnet.traccarSubnets[0].id, aws_subnet.traccarSubnets[1].id, aws_subnet.traccarSubnets[2].id]
}

resource "aws_lb_listener" "traccarALBL" {
  load_balancer_arn = aws_lb.traccarALB.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.traccarALBTG.arn
  }
}