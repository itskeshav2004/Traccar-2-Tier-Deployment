resource "aws_db_subnet_group" "traccarDBSGG" {
  name       = "traccardbsubnetgrp"
  subnet_ids = [aws_subnet.dbSubnets[0].id, aws_subnet.dbSubnets[1].id, aws_subnet.dbSubnets[2].id]
}

resource "aws_security_group" "traccarDBSG" {
  name   = "TraccarDB-SG"
  vpc_id = aws_vpc.traccarVPC.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_db_connection" {
  security_group_id            = aws_security_group.traccarDBSG.id
  referenced_security_group_id = aws_security_group.traccarSG.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.traccarDBSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_db_instance" "traccarDB" {
  engine                 = "mysql"
  engine_version         = "8.0.35"
  db_name                = "traccardb"
  identifier             = "traccardb"
  username               = "admin"
  password               = "admin123"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  publicly_accessible    = false
  network_type           = "IPV4"
  db_subnet_group_name   = aws_db_subnet_group.traccarDBSGG.name
  availability_zone      = var.availability_zone[0]
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.traccarDBSG.id]

  tags = {
    Name : "TraccarDB"
  }
}