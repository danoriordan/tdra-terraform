variable "container_registry" {
  description = "Container registry URL"
  type        = string
}

variable "minio_endpoint" {
  description = "MinIO service endpoint"
  type        = string
}

variable "qdrant_service_endpoint" {
  description = "Qdrant service endpoint"
  type        = string
}

variable "trino_service_endpoint" {
  description = "Trino service endpoint"
  type        = string
}

variable "azure_openai_endpoint" {
  description = "Azure OpenAI service endpoint"
  type        = string
  default     = ""
}

variable "azure_openai_api_key" {
  description = "Azure OpenAI API key"
  type        = string
  default     = ""
  sensitive   = true
}