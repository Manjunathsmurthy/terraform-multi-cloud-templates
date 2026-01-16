# IBM Cloud Virtual Private Cloud Module - Production-Ready

resource "ibm_is_vpc" "main" {
  name                      = var.vpc_name
  resource_group            = data.ibm_resource_group.group.id
  address_prefix_management = var.address_prefix_management

  tags = concat(var.common_tags, ["environment:${var.environment}"])
}

resource "ibm_is_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  name                    = "${var.environment}-public-subnet-${count.index + 1}"
  vpc                     = ibm_is_vpc.main.id
  zone                    = var.availability_zones[count.index % length(var.availability_zones)]
  ipv4_cidr_block         = var.public_subnet_cidrs[count.index]
  public_gateway          = ibm_is_public_gateway.public[count.index].id
  resource_group          = data.ibm_resource_group.group.id

  tags = concat(var.common_tags, ["type:public"])
}

resource "ibm_is_subnet" "private" {
  count           = length(var.private_subnet_cidrs)
  name            = "${var.environment}-private-subnet-${count.index + 1}"
  vpc             = ibm_is_vpc.main.id
  zone            = var.availability_zones[count.index % length(var.availability_zones)]
  ipv4_cidr_block = var.private_subnet_cidrs[count.index]
  resource_group  = data.ibm_resource_group.group.id

  tags = concat(var.common_tags, ["type:private"])
}

resource "ibm_is_public_gateway" "public" {
  count          = length(var.availability_zones)
  name           = "${var.environment}-public-gw-${count.index + 1}"
  vpc            = ibm_is_vpc.main.id
  zone           = var.availability_zones[count.index]
  resource_group = data.ibm_resource_group.group.id

  tags = concat(var.common_tags, ["type:gateway"])
}

resource "ibm_is_security_group" "public" {
  name            = "${var.environment}-public-sg"
  vpc             = ibm_is_vpc.main.id
  resource_group  = data.ibm_resource_group.group.id
  rules           = [
    {
      direction = "inbound"
      protocol  = "tcp"
      port_min  = 80
      port_max  = 80
    },
    {
      direction = "inbound"
      protocol  = "tcp"
      port_min  = 443
      port_max  = 443
    }
  ]

  tags = concat(var.common_tags, ["type:security-group"])
}

resource "ibm_is_security_group" "private" {
  name           = "${var.environment}-private-sg"
  vpc            = ibm_is_vpc.main.id
  resource_group = data.ibm_resource_group.group.id

  tags = concat(var.common_tags, ["type:security-group"])
}

data "ibm_resource_group" "group" {
  name = var.resource_group_name
}
