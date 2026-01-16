# OCI Virtual Cloud Network Module - Production-Ready

resource "oci_core_virtual_network" "main" {
  cidr_block     = var.vcn_cidr_block
  compartment_id = var.compartment_id
  display_name   = var.vcn_name

  freeform_tags = var.common_tags
}

resource "oci_core_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  cidr_block        = var.public_subnet_cidrs[count.index]
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_virtual_network.main.id
  display_name      = "${var.environment}-public-subnet-${count.index + 1}"
  availability_domain = data.oci_identity_availability_domains.available.availability_domains[count.index % length(data.oci_identity_availability_domains.available.availability_domains)].name
  prohibit_public_ip_on_instance = false
  route_table_id    = oci_core_route_table.public.id

  freeform_tags = merge(
    var.common_tags,
    { "Type" = "Public" }
  )
}

resource "oci_core_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  cidr_block        = var.private_subnet_cidrs[count.index]
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_virtual_network.main.id
  display_name      = "${var.environment}-private-subnet-${count.index + 1}"
  availability_domain = data.oci_identity_availability_domains.available.availability_domains[count.index % length(data.oci_identity_availability_domains.available.availability_domains)].name
  prohibit_public_ip_on_instance = true
  route_table_id    = oci_core_route_table.private.id

  freeform_tags = merge(
    var.common_tags,
    { "Type" = "Private" }
  )
}

resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.main.id
  display_name   = "${var.environment}-igw"

  freeform_tags = var.common_tags
}

resource "oci_core_nat_gateway" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.main.id
  display_name   = "${var.environment}-nat-gw"

  freeform_tags = var.common_tags
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.main.id
  display_name   = "${var.environment}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.main.id
  }

  freeform_tags = var.common_tags
}

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.main.id
  display_name   = "${var.environment}-private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.main.id
  }

  freeform_tags = var.common_tags
}

resource "oci_core_network_security_group" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.main.id
  display_name   = "${var.environment}-public-nsg"

  freeform_tags = var.common_tags
}

resource "oci_core_network_security_group" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.main.id
  display_name   = "${var.environment}-private-nsg"

  freeform_tags = var.common_tags
}

data "oci_identity_availability_domains" "available" {
  compartment_id = var.compartment_id
}
