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

#route table association
resource "aws_route_table_association" "database-assc" {
  subnet_id      = aws_subnet.public-01_database.id
  route_table_id = aws_route_table.private-route.id
}
