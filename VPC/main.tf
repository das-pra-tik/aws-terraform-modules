locals {
  vpc_tags = {
    Name        = "374278-Weighted-FailOver-Demo"
    Owner       = "374278"
    Environment = terraform.workspace
  }
}
data "aws_availability_zones" "available_az" {
  state = "available"
}

# Create non-default VPC for Prod
resource "aws_vpc" "demo-vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags                 = local.vpc_tags
}

# Create non-default Internet Gateway
resource "aws_internet_gateway" "demo-igw" {
  depends_on = [aws_vpc.demo-vpc]
  vpc_id     = aws_vpc.demo-vpc.id
  tags       = local.vpc_tags
}

resource "aws_subnet" "Public-subnet" {
  depends_on              = [aws_vpc.demo-vpc, aws_internet_gateway.demo-igw]
  for_each                = var.vpc-network-map
  vpc_id                  = aws_vpc.demo-vpc.id
  cidr_block              = each.value.public-subnet
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Tier = "374278-Public"
  }
}

resource "aws_route_table" "Public-rt" {
  depends_on = [aws_subnet.Public-subnet, aws_internet_gateway.demo-igw]
  vpc_id     = aws_vpc.demo-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
  }
  tags = local.vpc_tags
}

resource "aws_route_table_association" "public-rt-association" {
  depends_on     = [aws_subnet.Public-subnet, aws_route_table.Public-rt, aws_internet_gateway.demo-igw]
  for_each       = var.vpc-network-map
  subnet_id      = aws_subnet.Public-subnet[each.key].id
  route_table_id = aws_route_table.Public-rt.id
}

resource "aws_subnet" "Private-subnet" {
  depends_on              = [aws_vpc.demo-vpc]
  for_each                = var.vpc-network-map
  vpc_id                  = aws_vpc.demo-vpc.id
  cidr_block              = each.value.private-subnet
  availability_zone       = each.value.az
  map_public_ip_on_launch = false
  tags = {
    Tier = "374278-Private"
  }
}
resource "aws_route_table" "Private-rt" {
  depends_on = [aws_subnet.Private-subnet]
  vpc_id     = aws_vpc.demo-vpc.id
  tags       = local.vpc_tags
}
resource "aws_route_table_association" "private-rt-association" {
  depends_on     = [aws_subnet.Private-subnet, aws_route_table.Private-rt]
  for_each       = var.vpc-network-map
  subnet_id      = aws_subnet.Private-subnet[each.key].id
  route_table_id = aws_route_table.Private-rt.id
}
