variable "container_registry" {
  description = "Container registry URL"
  type        = string
}

variable "microsoft_app_id" {
  description = "Microsoft Bot Framework App ID"
  type        = string
  default     = ""
}

variable "microsoft_app_password" {
  description = "Microsoft Bot Framework App Password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "n8n_enabled" {
  description = "Enable n8n for orchestration"
  type        = bool
  default     = true
}

variable "langchain_enabled" {
  description = "Enable LangChain for agent orchestration"
  type        = bool
  default     = true
}

variable "qdrant_service_endpoint" {
  description = "Qdrant service endpoint"
  type        = string
}

variable "embedding_model_service_endpoint" {
  description = "Embedding model service endpoint"
  type        = string
}