// outputs.tf

output "pgvector_db_url" {
  value = "postgresql+psycopg://${var.pgvector_db_user}:${var.pgvector_db_password}@${var.host_ip}:${var.pgvector_db_host_port}/${var.pgvector_db_name}"
}

output "ollama_endpoint" {
  value = "http://${var.host_ip}:${var.ollama_host_port}"
}

output "open_webui_url" {
  value = "http://${var.host_ip}:${var.open_webui_host_port}"
}

output "rag_app_url" {
  value = "http://${var.host_ip}:${var.rag_app_host_port}"
}

