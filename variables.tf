variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "data-platform"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "data-platform-rg"
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    environment = "development"
    project     = "data-platform"
  }
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "default_node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 3
}

variable "default_node_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

variable "minio_storage_size" {
  description = "Storage size for MinIO (in GB)"
  type        = number
  default     = 100
}

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

variable "trino_memory_limit" {
  description = "Memory limit for Trino coordinator (in Mi)"
  type        = string
  default     = "4096Mi"
}

variable "trino_cpu_limit" {
  description = "CPU limit for Trino coordinator"
  type        = string
  default     = "2"
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

variable "azure_ai_services_enabled" {
  description = "Enable Azure AI Services"
  type        = bool
  default     = true
}