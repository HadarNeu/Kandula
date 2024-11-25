

#### Getting the data of the available availability zones ####
data "aws_availability_zones" "available" {}


#### Creating a VPC   ######
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block

  tags = {
    "Name" = "${var.vpc_name}"
    # "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "vpc"
  }

}

#### Creating public subnets #####
resource "aws_subnet" "public" {
  map_public_ip_on_launch = "true"
  count                   = length(var.public_subnets_cidr_list)
  cidr_block              = var.public_subnets_cidr_list[count.index]
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = "public-subnet-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${var.project_name}"
    # "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    # "kubernetes.io/role/internal-elb"             = "1"
    "tier" = "public"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "subnet"
  }
}

#### Creating private subnets #####
resource "aws_subnet" "private" {
  count                   = length(var.private_subnets_cidr_list)
  cidr_block              = var.private_subnets_cidr_list[count.index]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "false"
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    "Name" = "private-subnet-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${var.project_name}"
    # "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    # "kubernetes.io/role/internal-elb"             = "1"
    "tier" = "private"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "subnet"
  }
}

#### Creating Internet gateway ####
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "igw-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "igw"
  }
}

#### Elasic IPs for NAT ####
resource "aws_eip" "eip" {
  count = length(var.private_subnets_cidr_list)

  tags = {
    "Name" = "eip-nat-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "eip"
  }
}

#### NAT Gateways ####
resource "aws_nat_gateway" "nat" {
  count         = length(var.private_subnets_cidr_list)
  allocation_id = aws_eip.eip.*.id[count.index]
  subnet_id     = aws_subnet.public.*.id[count.index]

  tags = {
    "Name" = "nat-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "nat"
  }
}


#####################
###### ROUTING ######
#####################

#### Creating a public route table ####
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "public-route-table-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "route-table"
    "tier" = "public"
  }
}

#### Creating private route tables ####
resource "aws_route_table" "private_route_tables" {
  count  = length(var.private_subnets_cidr_list)
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "private-route-table-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "route-table"
    "tier" = "private"
  }
}

#### Public route table association ####
resource "aws_route_table_association" "public" {
  depends_on = [ 
    aws_route_table.public_route_table,
    aws_subnet.public
  ]
  count          = length(var.public_subnets_cidr_list)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public_route_table.id
}

#### Private route table association ####
resource "aws_route_table_association" "private" {
    depends_on = [ 
    aws_route_table.private_route_tables,
    aws_subnet.private
  ]
  count          = length(var.private_subnets_cidr_list)
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private_route_tables[count.index].id
}

#### Public route for the public route table ####
resource "aws_route" "igw_public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

#### Public route for private route tables ####
resource "aws_route" "nat_private_route" {
  count                  = length(var.private_subnets_cidr_list)
  route_table_id         = aws_route_table.private_route_tables.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.*.id[count.index]
}

