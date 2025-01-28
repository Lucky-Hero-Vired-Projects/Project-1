resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "capstone-eks-vpc"
  }
}

// Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "capstone-igw"
  }
}

// Elastic IP for NAT Gateway
resource "aws_eip" "nat_ip" {
  domain = "vpc"
}

// Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                    = "public-subnet-${count.index}"
    "kubernetes.io/role/elb" = "1"
  }
}

// Private Subnets
resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name                           = "private-subnet-${count.index}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

// NAT Gateway (Single NAT Gateway)
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.public[0].id # Attach to the first public subnet

  tags = {
    Name = "capstone-gw-NAT"
  }

  depends_on = [aws_internet_gateway.this]
}

// Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "capstone-public-route-table"
  }
}

// Public Route Table Associations
resource "aws_route_table_association" "public_association" {
  count        = length(aws_subnet.public)
  subnet_id    = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

// Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "capstone-private-route-table"
  }
}

// Private Route Table Associations
resource "aws_route_table_association" "private_association" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

// Availability Zones Data
data "aws_availability_zones" "available" {
  state = "available"
}
