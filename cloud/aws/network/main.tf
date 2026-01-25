# AWS Network Module
# Creates subnets, NAT gateways, and route tables

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# =============================================================================
# Local Variables
# =============================================================================

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }

  # Calculate subnet CIDRs
  public_subnets  = [for i, az in var.availability_zones : cidrsubnet(var.network_cidr, 4, i)]
  private_subnets = [for i, az in var.availability_zones : cidrsubnet(var.network_cidr, 4, i + 4)]
}

# =============================================================================
# Public Subnets
# =============================================================================

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = var.vpc_id
  cidr_block              = local.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name                     = "${var.project}-${var.environment}-public-${var.availability_zones[count.index]}"
    "kubernetes.io/role/elb" = "1"
    Type                     = "public"
  })
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# =============================================================================
# Private Subnets
# =============================================================================

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = var.vpc_id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(local.common_tags, {
    Name                              = "${var.project}-${var.environment}-private-${var.availability_zones[count.index]}"
    "kubernetes.io/role/internal-elb" = "1"
    Type                              = "private"
  })
}

# =============================================================================
# NAT Gateway (Single for dev, Multi-AZ for prd)
# =============================================================================

resource "aws_eip" "nat" {
  count  = var.environment == "prd" ? length(var.availability_zones) : 1
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-nat-eip-${count.index + 1}"
  })

  depends_on = [var.internet_gateway_id]
}

resource "aws_nat_gateway" "main" {
  count = var.environment == "prd" ? length(var.availability_zones) : 1

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-nat-${count.index + 1}"
  })
}

resource "aws_route_table" "private" {
  count = var.environment == "prd" ? length(var.availability_zones) : 1

  vpc_id = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-private-rt-${count.index + 1}"
  })
}

resource "aws_route" "private_nat" {
  count = var.environment == "prd" ? length(var.availability_zones) : 1

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.environment == "prd" ? count.index : 0].id
}
