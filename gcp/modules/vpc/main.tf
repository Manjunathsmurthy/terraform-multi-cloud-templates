# GCP Virtual Private Cloud Module - Production-Ready

resource "google_compute_network" "main" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_subnetwork" "public" {
  count                    = length(var.public_subnet_cidrs)
  name                     = "${var.environment}-public-subnet-${count.index + 1}"
  ip_cidr_range           = var.public_subnet_cidrs[count.index]
  region                  = var.region
  network                 = google_compute_network.main.id
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "private" {
  count                    = length(var.private_subnet_cidrs)
  name                     = "${var.environment}-private-subnet-${count.index + 1}"
  ip_cidr_range           = var.private_subnet_cidrs[count.index]
  region                  = var.region
  network                 = google_compute_network.main.id
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_router" "public" {
  count   = var.create_cloud_nat ? 1 : 0
  name    = "${var.environment}-public-router"
  region  = var.region
  network = google_compute_network.main.id

  bgp {
    asn = var.bgp_asn
  }
}

resource "google_compute_router_nat" "public" {
  count                              = var.create_cloud_nat ? 1 : 0
  name                               = "${var.environment}-cloud-nat"
  router                             = google_compute_router.public[0].name
  region                             = google_compute_router.public[0].region
  nat_ip_allocate_option            = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${var.environment}-allow-internal"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = concat(var.public_subnet_cidrs, var.private_subnet_cidrs)
}

resource "google_compute_firewall" "allow_ssh" {
  count   = var.allow_ssh ? 1 : 0
  name    = "${var.environment}-allow-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges
}
