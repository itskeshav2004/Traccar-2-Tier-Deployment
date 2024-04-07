data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_key_pair" "traccarKey" {
  key_name   = "traccarkey"
  public_key = file("traccarkey.pub")
}

resource "aws_security_group" "ansibleSG" {
  name   = "Ansible-Server-SG"
  vpc_id = aws_vpc.traccarVPC.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ports" {
  security_group_id = aws_security_group.ansibleSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ipv4" {
  security_group_id = aws_security_group.ansibleSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "ansibleServer" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.traccarKey.key_name
  subnet_id              = aws_subnet.traccarSubnets[0].id
  vpc_security_group_ids = [aws_security_group.ansibleSG.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y software-properties-common
              sudo add-apt-repository --yes --update ppa:ansible/ansible
              sudo apt install -y ansible
              EOF

  tags = {
    Name = "ANSIBLE SERVER"
  }
}

resource "aws_security_group" "traccarSG" {
  name   = "Traccar-Server-SG"
  vpc_id = aws_vpc.traccarVPC.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_connection" {
  count             = 3
  security_group_id = aws_security_group.traccarSG.id
  cidr_ipv4         = var.src_cidr[count.index]
  from_port         = var.port[count.index]
  ip_protocol       = "tcp"
  to_port           = var.port[count.index]
}

resource "aws_vpc_security_group_ingress_rule" "allow_gps_ports" {
  security_group_id = aws_security_group.traccarSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 6000
}

resource "aws_vpc_security_group_ingress_rule" "allow_ansible_ssh" {
  security_group_id            = aws_security_group.traccarSG.id
  referenced_security_group_id = aws_security_group.ansibleSG.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.traccarSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "traccarEC2" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.traccarKey.key_name
  subnet_id              = aws_subnet.traccarSubnets[count.index].id
  vpc_security_group_ids = [aws_security_group.traccarSG.id]

  tags = {
    "Name" = "TRACCAR SERVER ${count.index + 1}"
  }
}

output "private_ip" {
  value = aws_instance.traccarEC2[*].private_ip
}