// main.tf
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = var.docker_host
}

# Network for AI stack
resource "docker_network" "ai_net" {
  name = var.network_name
}

## PGVector
resource "docker_image" "pgvector_db" {
  name         = var.pgvector_db_image
  keep_locally = true
}

# Persistent volume for PGVector DB
resource "docker_volume" "pgvector_db_data" {
  name = var.pgvector_db_volume_name
}

# Postgres with pgvector
resource "docker_container" "pgvector_db" {
  name  = var.pgvector_db_container_name
  image = var.pgvector_db_image  # PostgreSQL with pgvector preinstalled [web:258][web:266]

  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.ai_net.name
  }

  ports {
    internal = 5432
    external = var.pgvector_db_host_port
  }

  volumes {
    #volume_name    = docker_volume.postgres_data.name
    host_path = var.pgvector_db_host_path
    container_path = "/var/lib/postgresql/data"
  }

  env = [
    "POSTGRES_USER=${var.pgvector_db_user}",
    "POSTGRES_PASSWORD=${var.pgvector_db_password}",
    "POSTGRES_DB=${var.pgvector_db_name}",
  ]

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U ${var.pgvector_db_user}"]
    interval = "10s"
    timeout  = "5s"
    retries  = 5
  }
}

## Ollama
resource "docker_image" "ollama" {
  name         = var.ollama_image
  keep_locally = true
}

# Persistent volume for Ollama model data
resource "docker_volume" "ollama_data" {
  name = var.ollama_volume_name
}

# Ollama container
resource "docker_container" "ollama" {
  name  = var.ollama_container_name
  image = var.ollama_image

  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.ai_net.name
  }

  ports {
    internal = 11434
    external = var.ollama_host_port
  }

  volumes {
    #volume_name    = docker_volume.ollama_data.name
    host_path = var.ollama_host_path
    container_path = "/root/.ollama"
  }

  # Optional: extra resources/env tuning for Apple Silicon
  env = [
    "OLLAMA_NUM_THREADS=${var.ollama_num_threads}",
    "OLLAMA_MAX_LOADED_MODELS=${var.ollama_max_loaded_models}",
  ]
  
  # Simple healthcheck so we know when API is ready
  healthcheck {
    test     = ["CMD-SHELL", "bash", "-c", "</dev/tcp/localhost/11434"]
    interval = "10s"
    timeout  = "5s"
    retries  = 5
  }
}

# On¸e-shot container that pulls models via Ollama HTTP API
resource "docker_container" "ollama_model_pull" {
  name  = "ollama-model-pull"
  image = "curlimages/curl:latest"

  # Wait until Ollama is healthy
  depends_on = [docker_container.ollama]

  restart = "no"

  networks_advanced {
    name = docker_network.ai_net.name
  }

  # NOTE: use the container name "ollama" on the Docker network
  # Pull Phi, Mistral, and a small Llama variant – adjust names as you like.
  command = [
    "sh",
    "-c",
    "set -e; echo 'Pulling phi...'; curl -X POST http://ollama:11434/api/pull -H 'Content-Type: application/json' -d '{\"name\":\"phi\"}'; echo 'Pulling mistral...'; curl -X POST http://ollama:11434/api/pull -H 'Content-Type: application/json' -d '{\"name\":\"mistral\"}'; echo 'Pulling llama3...'; curl -X POST http://ollama:11434/api/pull -H 'Content-Type: application/json' -d '{\"name\":\"llama3\"}'; curl -X POST http://ollama:11434/api/pull -H 'Content-Type: application/json' -d '{\"name\":\"nomic-embed-text\"}'; echo 'All models pulled.'"
  ]
}

## Open WebUI
resource "docker_image" "open_webui" {
  name         = var.open_webui_image
  keep_locally = true
}

resource "docker_volume" "openwebui_data" {
  name = "openwebui-data"
}

# Open WebUI container
resource "docker_container" "open_webui" {
  name  = var.open_webui_container_name
  image =  var.open_webui_image

  depends_on = [
   docker_container.ollama,
   docker_container.rag_app,
  ]

  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.ai_net.name
  }

  ports {
    internal = 8080
    external = var.open_webui_host_port
  }

  # Point WebUI at Ollama service on the Docker network
  env = [
    "OLLAMA_BASE_URL=http://${docker_container.ollama.name}:${var.ollama_host_port}",
    "OPENAI_API_BASE=http://rag-app:8082/v1",
    "OPENAI_API_KEY=dev-key",  # WebUI will send "Authorization: Bearer dev-key"
  ]

  volumes {
    #volume_name    = docker_volume.openwebui_data.name
    host_path      = var.open_webui_host_path
    container_path = "/app/backend/data"
  }

  volumes {
    host_path      = var.open_webui_terraform_host_path
    container_path = "/infra"
    #read_only      = true
  }

  volumes {
    host_path      = var.open_webui_plugins_host_path
    container_path = "/app/plugins/tools"
    read_only      = true
  }

  healthcheck {
    test     = ["CMD-SHELL", "curl --silent --fail http://localhost:8080/health || exit 1"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }
}

# RAG API
resource "docker_image" "rag_app" {
  name = "${var.rag_app_image}:latest"

  build {
    context    = "${path.module}/embeddings"
    dockerfile = "${path.module}/embeddings/Dockerfile"
  }
}

resource "docker_container" "rag_app" {
  name  = var.rag_app_container_name
  image = "${var.rag_app_image}:latest"

  depends_on = [
    docker_container.pgvector_db,
    docker_container.ollama,
    docker_container.ollama_model_pull,
    docker_image.rag_app,
  ]

  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.ai_net.name
  }

  ports {
    internal = 8082
    external = var.rag_app_host_port
  }

  healthcheck {
    test     = ["CMD-SHELL", "curl --silent -H 'Authorization: Bearer dev-key' -X POST  http://localhost:8082/openai/verify --fail || exit 1"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }

}

