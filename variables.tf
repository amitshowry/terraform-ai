// variables.tf
variable "docker_host" {
  description = "Docker daemon host"
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "host_ip" {
  description = "Host machine IP address"
  type        = string
  default     = "localhost"
}

variable "network_name" {
  type        = string
  default     = "ai-net"
  description = "Docker network for AI stack"
}

# PGVECTOR DB
variable "pgvector_db_volume_name" {
  type        = string
  default     = "pgvector-db-data"
  description = "Docker volume name for PGVector DB"
}

variable "pgvector_db_container_name" {
  type        = string
  default     = "pgvector-db"
  description = "Container name for pgvector_db"
}

variable "pgvector_db_image" {
  type        = string
  default     = "pgvector/pgvector:pg17" 
  description = "pgvector_db Docker image"
}

variable "pgvector_db_user" {
  description = "PGVector DB (PostgreSQL) user"
  type        = string
  default     = "postgres"
}

variable "pgvector_db_password" {
  description = "PGVector DB (PostgreSQL) password"
  type    = string
  default = "password"
}

variable "pgvector_db_name" {
  description = "PGVector DB (PostgreSQL) name"
  type    = string
  default = "admin"
}

variable "pgvector_db_host_path" {
  description = "PGVector DB (PostgresSQL) data volume local host path"
  type        = string
  default     = "/tmp/pgvector-db-data"
}

variable "pgvector_db_host_port" {
  description = "PGVector DB (PostgresSQL) TCP port"
  type        = number
  default     = 5432
}


# Ollama 
variable "ollama_volume_name" {
  type        = string
  default     = "ollama-data"
  description = "Docker volume name for Ollama models"
}

variable "ollama_host_path" {
  type        = string
  default     = "/tmp/ollama-data"
  description = "Local Host Path name for Ollama models"
}

variable "ollama_container_name" {
  type        = string
  default     = "ollama"
  description = "Container name for Ollama"
}

variable "ollama_image" {
  type        = string
  default     = "ollama/ollama:latest"
  description = "Ollama Docker image"
}

variable "ollama_host_port" {
  type        = number
  default     = 11434
  description = "Host port to expose Ollama API"
}

variable "ollama_num_threads" {
  type        = number
  default     = 6
  description = "Number of threads used by Ollama"
}

variable "ollama_max_loaded_models" {
  type        = number
  default     = 2
  description = "Max simultaneously loaded models"
}


# Open WebUI
variable "open_webui_volume_name" {
  type        = string
  default     = "openwebui-data"
  description = "Docker volume name for Open WebUI"
}

variable "open_webui_host_path" {
  type        = string
  default     = "/tmp/openwebui-data"
  description = "Local Host Path name for Open WebUI"
}

variable "open_webui_terraform_host_path" {
  type        = string
  default     = "/tmp/openwebui-terraform-data"
  description = "Local Host Path name for Terraform Modules"
}

variable "open_webui_plugins_host_path" {
  type        = string
  default     = "/tmp/openwebui-plugin-data"
  description = "Local Host Path name for Plugins"
}

variable "open_webui_container_name" {
  type        = string
  default     = "open-webui"
  description = "Container name for Open WebUI"
}

variable "open_webui_image" {
  type        = string
  default     = "ghcr.io/open-webui/open-webui:main"
  description = "Open WebUI Docker image"
}

variable "open_webui_host_port" {
  type        = number
  default     = 8080
  description = "Host port to expose Open WebUI"
}


# RAG APP
variable "rag_app_image" {
  type        = string
  default     = "rag-app"
  description = "RAG API Docker image"
}

variable "rag_app_container_name" {
  type        = string
  default     = "rag-app"
  description = "Container name for RAG API"
}

variable "rag_app_host_port" {
  type        = number
  default     = 8082
  description = "Host port to expose RAG API"
}
