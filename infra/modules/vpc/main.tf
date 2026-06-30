locals {
  public_subnets = {
    for index, cidr in var.public_subnet_cidrs : index => {
      cidr = cidr
      az   = var.availability_zones[index]
    }
  }

  private_app_subnets = {
    for index, cidr in var.private_app_subnet_cidrs : index => {
      cidr = cidr
      az   = var.availability_zones[index]
    }
  }

  private_db_subnets = {
    for index, cidr in var.private_db_subnet_cidrs : index => {
      cidr = cidr
      az   = var.availability_zones[index]
    }
  }

  nat_gateway_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0

  nat_gateways = {
    for index in range(local.nat_gateway_count) : index => {
      subnet_key = var.single_nat_gateway ? 0 : index
    }
  }

  common_tags = merge(var.tags, { Module = "vpc" })
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, { Name = var.name })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, { Name = "${var.name}-igw" })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                                      = "${var.name}-public-${each.value.az}"
    Tier                                      = "public"
    "kubernetes.io/role/elb"                 = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

resource "aws_subnet" "private_app" {
  for_each = local.private_app_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name                                         = "${var.name}-private-app-${each.value.az}"
    Tier                                         = "private-app"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

resource "aws_subnet" "private_db" {
  for_each = local.private_db_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${var.name}-private-db-${each.value.az}"
    Tier = "private-db"
  })
}

resource "aws_eip" "nat" {
  for_each = local.nat_gateways

  domain = "vpc"

  tags = merge(local.common_tags, { Name = "${var.name}-nat-eip-${each.key + 1}" })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  for_each = local.nat_gateways

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.value.subnet_key].id

  tags = merge(local.common_tags, { Name = "${var.name}-nat-${each.key + 1}" })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.common_tags, { Name = "${var.name}-public-rt" })
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_app" {
  for_each = local.private_app_subnets

  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[each.key].id
    }
  }

  tags = merge(local.common_tags, { Name = "${var.name}-private-app-rt-${each.value.az}" })
}

resource "aws_route_table_association" "private_app" {
  for_each = aws_subnet.private_app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_app[each.key].id
}

resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, { Name = "${var.name}-private-db-rt" })
}

resource "aws_route_table_association" "private_db" {
  for_each = aws_subnet.private_db

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_db.id
}
