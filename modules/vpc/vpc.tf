locals {
  pub_cfg = {
    for i, cidr in var.public_subnets :
    i => { cidr = cidr, az = var.availability_zones[i] }
  }
  priv_cfg = {
    for i, cidr in var.private_subnets :
    i => { cidr = cidr, az = var.availability_zones[i] }
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name      = var.vpc_name
    ManagedBy = "Terraform"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name      = "${var.vpc_name}-igw"
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "public" {
  for_each = local.pub_cfg
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Name      = "${var.vpc_name}-public-${each.key}"
    ManagedBy = "Terraform"
    Tier      = "public"
  }
}

resource "aws_subnet" "private" {
  for_each = local.priv_cfg
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name      = "${var.vpc_name}-private-${each.key}"
    ManagedBy = "Terraform"
    Tier      = "private"
  }
}

# Allocate one EIP per NAT (per AZ)
resource "aws_eip" "nat" {
  for_each = local.pub_cfg
  domain   = "vpc"
  tags = {
    Name      = "${var.vpc_name}-eip-${each.key}"
    ManagedBy = "Terraform"
  }
}

resource "aws_nat_gateway" "nat" {
  for_each      = local.pub_cfg
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  tags = {
    Name      = "${var.vpc_name}-nat-${each.key}"
    ManagedBy = "Terraform"
  }
  depends_on = [aws_internet_gateway.igw]
}
