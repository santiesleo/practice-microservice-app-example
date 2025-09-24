# ===========================================
# VARIABLES FOR STAGING ENVIRONMENT
# ===========================================

# GCP Project Configuration
variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "microservices-devops-0923"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

# Networking Configuration
variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "pods_cidr" {
  description = "CIDR block for pods"
  type        = string
  default     = "10.1.0.0/16"
}

variable "services_cidr" {
  description = "CIDR block for services"
  type        = string
  default     = "10.2.0.0/16"
}

# GKE Configuration
variable "node_count" {
  description = "Number of nodes in the cluster"
  type        = number
  default     = 2
}

variable "min_node_count" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes"
  type        = number
  default     = 5
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-small"
}

variable "preemptible_nodes" {
  description = "Use preemptible nodes"
  type        = bool
  default     = true
}

variable "disk_size_gb" {
  description = "Disk size for nodes in GB"
  type        = number
  default     = 20
}

# Redis Configuration
variable "redis_memory_size" {
  description = "Memory size for Redis instance in GB"
  type        = number
  default     = 1
}

# Application Configuration
variable "app_name" {
  description = "Application name"
  type        = string
  default     = "microservices"
}

variable "app_version" {
  description = "Application version"
  type        = string
  default     = "latest"
}

# Tags
variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default = {
    environment = "staging"
    project     = "microservices"
    managed-by  = "terraform"
    owner       = "devops-team"
  }
}