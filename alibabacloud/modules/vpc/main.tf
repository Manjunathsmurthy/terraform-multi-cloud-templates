# Alibaba Cloud Virtual Private Cloud Module - Production-Ready

resource "alibabacloud_vpc" "main" {
  vpc_name   = var.vpc_name
  cidr_block = var.vpc_cidr_block
  description = var.vpc_description

  tags = var.common_tags
}

resource "alibabacloud_vswitch" "public" {
  count             = length(var.public_vswitch_cidrs)
  vpc_id            = alibabacloud_vpc.main.id
  cidr_block        = var.public_vswitch_cidrs[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  vswitch_name      = "${var.environment}-public-vswitch-${count.index + 1}"
  description       = "Public Virtual Switch ${count.index + 1}"

  tags = merge(
    var.common_tags,
    { "Type" = "Public" }
  )
}

resource "alibabacloud_vswitch" "private" {
  count             = length(var.private_vswitch_cidrs)
  vpc_id            = alibabacloud_vpc.main.id
  cidr_block        = var.private_vswitch_cidrs[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  vswitch_name      = "${var.environment}-private-vswitch-${count.index + 1}"
  description       = "Private Virtual Switch ${count.index + 1}"

  tags = merge(
    var.common_tags,
    { "Type" = "Private" }
  )
}

resource "alibabacloud_security_group" "public" {
  name   = "${var.environment}-public-sg"
  vpc_id = alibabacloud_vpc.main.id
  description = "Public Security Group"

  tags = var.common_tags
}

resource "alibabacloud_security_group" "private" {
  name   = "${var.environment}-private-sg"
  vpc_id = alibabacloud_vpc.main.id
  description = "Private Security Group"

  tags = var.common_tags
}

resource "alibabacloud_eip" "nat" {
  count           = var.create_nat_gateway ? 1 : 0
  address_type    = "EIP"
  internet_charge_type = "PayByTraffic"
  bandwidth       = 100

  tags = var.common_tags
}

resource "alibabacloud_nat_gateway" "main" {
  count          = var.create_nat_gateway ? 1 : 0
  vpc_id         = alibabacloud_vpc.main.id
  nat_gateway_name = "${var.environment}-nat-gw"
  specification  = "Small"

  depends_on = [alibabacloud_vswitch.public]

  tags = var.common_tags
}

resource "alibabacloud_eip_association" "nat" {
  count        = var.create_nat_gateway ? 1 : 0
  allocation_id = alibabacloud_eip.nat[0].id
  instance_id  = alibabacloud_nat_gateway.main[0].id
}
