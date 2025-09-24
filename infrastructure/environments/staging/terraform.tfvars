# ===========================================
# STAGING ENVIRONMENT VARIABLES
# ===========================================

# GCP Configuration
project_id = "microservices-devops-0923"
region     = "us-central1"
zone       = "us-central1-a"
environment = "staging"

# Networking
subnet_cidr    = "10.0.0.0/24"
pods_cidr      = "10.1.0.0/16"
services_cidr  = "10.2.0.0/16"

# GKE Configuration (OPTIMIZED FOR COST)
node_count        = 1  # Mínimo para funcionar
min_node_count    = 1
max_node_count    = 2  # Máximo para emergencias
machine_type      = "e2-small"  # Más barato pero funcional
preemptible_nodes = false
disk_size_gb      = 10  # Mínimo necesario

# Redis Configuration
redis_memory_size = 1  # Mínimo

# Application
app_name    = "microservices"
app_version = "latest"

# Tags
tags = {
  environment = "staging"
  project     = "microservices"
  managed-by  = "terraform"
  owner       = "devops-team"
  cost-center = "engineering"
}