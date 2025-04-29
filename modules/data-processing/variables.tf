variable "qdrant_storage_size" {
  description = "Storage size for Qdrant vector store (in GB)"
  type        = number
  default     = 20
}

variable "rdf_graph_storage_size" {
  description = "Storage size for RDF Graph DB (in GB)"
  type        = number
  default     = 20
}

variable "trino_cpu_limit" {
  description = "CPU limit for Trino"
  type        = string
  default     = "2"
}

variable "trino_memory_limit" {
  description = "Memory limit for Trino (in Mi)"
  type        = string
  default     = "4096Mi"
}

variable "minio_endpoint" {
  description = "MinIO service endpoint"
  type        = string
}

variable "container_registry" {
  description = "Container registry URL"
  type        = string
}

variable "azure_ai_services_enabled" {
  description = "Enable Azure AI Services"
  type        = bool
  default     = true
}

variable "azure_ai_endpoint" {
  description = "Azure AI Services endpoint"
  type        = string
  default     = ""
}

variable "azure_ai_key" {
  description = "Azure AI Services key"
  type        = string
  default     = ""
  sensitive   = true
}