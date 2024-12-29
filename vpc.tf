resource "aws_vpc" "VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc"
  }
}
#adding subnet , here VPC id shud take from abovie vpc id
resource "aws_subnet" "public-01_FRontenf" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public-01_FRontenf"
  }
}
resource "aws_subnet" "public-01_backend" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public-01_backend"
  }
}
resource "aws_subnet" "public-01_database" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "public-01_database"
  }
}
#adding gateway and attaching 
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "gateway"
  }
}
#creating route tables - public
resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "public-route"
  }
}
#route table association for public both Frontend and backend
resource "aws_route_table_association" "Frontend-assc" {
  subnet_id      = aws_subnet.public-01_FRontenf.id
  route_table_id = aws_route_table.public-route.id
}

#route table association
resource "aws_route_table_association" "backend-assc" {
  subnet_id      = aws_subnet.public-01_backend.id
  route_table_id = aws_route_table.public-route.id
}
#creating route tables - private
resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "private-route"
  }
}

#route table association with private
resource "aws_route_table_association" "database-assc" {
  subnet_id      = aws_subnet.public-01_database.id
  route_table_id = aws_route_table.private-route.id
}

#NACL will create automatically while creating assocites 
#here we are just creting for to know
resource "aws_network_acl" "my_NACL" {
  vpc_id = aws_vpc.VPC.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "my_NACL"
  }
}

##security groups we need to create
## creating SG for frontend
resource "aws_security_group" "Frontend_SG" {
  name        = "Frontend SG"
  description = "Allow Frontend traffic"
  vpc_id      = aws_vpc.VPC.id

  tags = {
    Name = "Frontend_SG"
  }
}
#adding ingress and egress rules 

resource "aws_vpc_security_group_ingress_rule" "Frontend_ingress" {
  security_group_id = aws_security_group.Frontend_SG.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 63325
}

resource "aws_vpc_security_group_egress_rule" "Frontend_ingress" {
  security_group_id = aws_security_group.Frontend_SG.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 63325
}
## creating SG for backend - Node 8080
resource "aws_security_group" "backend_SG" {
  name        = "backend SG"
  description = "Allow backend traffic"
  vpc_id      = aws_vpc.VPC.id

  tags = {
    Name = "backend_SG"
  }
}
#adding ingress and egress rules

resource "aws_vpc_security_group_ingress_rule" "backedend_ingress" {
  security_group_id = aws_security_group.backend_SG.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 8080
  ip_protocol = "tcp"
  to_port     = 8080
}

resource "aws_vpc_security_group_egress_rule" "backend_egress" {
  security_group_id = aws_security_group.backend_SG.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 63325
}
## creating SG for backend - Postgress 5432
resource "aws_security_group" "database_SG" {
  name        = "database SG"
  description = "Allow database traffic"
  vpc_id      = aws_vpc.VPC.id

  tags = {
    Name = "database_SG"
  }
}
#adding ingress and egress rules

resource "aws_vpc_security_group_ingress_rule" "database_ingress" {
  security_group_id = aws_security_group.database_SG.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 5432
  ip_protocol = "tcp"
  to_port     = 5432
}

resource "aws_vpc_security_group_egress_rule" "database_egress" {
  security_group_id = aws_security_group.database_SG.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 63325
}

