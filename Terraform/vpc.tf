resource "aws_vpc" "traccarVPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "TraccarVPC"
  }
}

resource "aws_subnet" "traccarSubnets" {
  count                   = 3
  vpc_id                  = aws_vpc.traccarVPC.id
  cidr_block              = var.cidr_block[count.index]
  availability_zone       = var.availability_zone[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_name[count.index]
  }
}

resource "aws_subnet" "dbSubnets" {
  count                   = 3
  vpc_id                  = aws_vpc.traccarVPC.id
  cidr_block              = var.db_cidr_block[count.index]
  availability_zone       = var.availability_zone[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = var.db_subnet_name[count.index]
  }
}

resource "aws_internet_gateway" "traccarIGW" {
  vpc_id = aws_vpc.traccarVPC.id

  tags = {
    Name = "TraccarIGW"
  }
}

resource "aws_route_table" "traccarRT" {
  vpc_id = aws_vpc.traccarVPC.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.traccarIGW.id
  }

  tags = {
    Name = "TraccarRT"
  }
}

resource "aws_route_table" "dbRT" {
  vpc_id = aws_vpc.traccarVPC.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "DBRT"
  }
}

resource "aws_route_table_association" "traccarRTA" {
  count          = 3
  subnet_id      = aws_subnet.traccarSubnets[count.index].id
  route_table_id = aws_route_table.traccarRT.id
}

resource "aws_route_table_association" "dbRTA" {
  count          = 3
  subnet_id      = aws_subnet.dbSubnets[count.index].id
  route_table_id = aws_route_table.dbRT.id
}