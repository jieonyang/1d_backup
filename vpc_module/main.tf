#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * NAT Gateway
#  * Route Table
#  * EIP
#

data "aws_availability_zones" "available" {}

resource "aws_vpc" "terra" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "mgmt-vpc",
  }
}


resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.terra.id
  
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index+1}.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name  = "mgmt-public-sub0${count.index+1}"
  }
}


resource "aws_subnet" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.terra.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.1${count.index}.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "mgmt-private-sub0${count.index+1}"
  }
}


resource "aws_internet_gateway" "terra" {
  vpc_id = aws_vpc.terra.id

  tags = {
    Name = "mgmt-ig"
  }
}

resource "aws_nat_gateway" "terra" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on    = [aws_internet_gateway.terra]

  tags = {
    Name = "mgmt-nat-gateway-01"
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.terra.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra.id
  }

  tags = {
    Name = "mgmt-route-public-01"
  }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.terra.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terra.id
  }

  tags = {
    Name = "mgmt-route-private-01"
  }
}


resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.id
}


resource "aws_eip" "nat" {
  vpc        = true
  depends_on = [aws_internet_gateway.terra]

  tags = {
    Name = "NAT on mgmt-cluster"
  }
}
