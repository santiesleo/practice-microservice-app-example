# ===========================================
# TERRAFORM CONFIGURATION
# ===========================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  backend "gcs" {
    bucket = "microservices-devops-0923-terraform-state"
    prefix = "terraform/state"
  }
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# ===========================================
# DATA SOURCES
# ===========================================

# Get current project
data "google_project" "current" {}

# ===========================================
# ENABLE REQUIRED APIS
# ===========================================

resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "redis.googleapis.com", # Added for Memorystore
  ])
  project = var.project_id
  service = each.key
  disable_on_destroy = false
}

# ===========================================
# GKE CLUSTER - ULTRA SIMPLE CONFIGURATION
# ===========================================

resource "google_container_cluster" "primary" {
  name     = "${var.app_name}-cluster-${var.environment}-v3"
  location = var.zone  # Usar zona específica en lugar de región para reducir cuota
  
  # Keep default node pool for simplicity
  remove_default_node_pool = false
  initial_node_count       = 2
  
  # Disable deletion protection for easier management
  deletion_protection = false
  
  depends_on = [google_project_service.required_apis]
}

# ===========================================
# GKE NODE POOL - Using default pool for simplicity
# ===========================================

# resource "google_container_node_pool" "primary_nodes" {
#   name       = "${var.app_name}-nodes-${var.environment}"
#   location   = var.zone
#   cluster    = google_container_cluster.primary.name

#   # Autoscaling configuration
#   autoscaling {
#     min_node_count = var.min_node_count
#     max_node_count = var.max_node_count
#   }

#   node_config {
#     machine_type = var.machine_type
#     disk_size_gb = var.disk_size_gb
#     disk_type    = "pd-standard"
#     preemptible  = var.preemptible_nodes

#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]

#     labels = var.tags

#     tags = ["gke-node", var.app_name]
#   }

#   depends_on = [google_container_cluster.primary]
# }

# ===========================================
# REDIS MEMORYSTORE
# ===========================================

resource "google_redis_instance" "redis" {
  name           = "${var.app_name}-redis-${var.environment}"
  tier           = "BASIC"
  memory_size_gb = var.redis_memory_size

  region = var.region

  location_id = var.zone

  redis_version = "REDIS_7_0"

  display_name = "Redis for ${var.app_name} ${var.environment}"

  labels = var.tags

  depends_on = [google_project_service.required_apis]
}

# ===========================================
# OUTPUTS
# ===========================================

output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "redis_host" {
  description = "Redis Memorystore host"
  value       = google_redis_instance.redis.host
  sensitive   = true
}

output "redis_port" {
  description = "Redis Memorystore port"
  value       = google_redis_instance.redis.port
}