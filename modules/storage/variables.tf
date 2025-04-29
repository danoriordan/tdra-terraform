variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "minio_storage_size" {
  description = "Storage size for MinIO (in GB)"
  type        = number
  default     = 100
}

variable "delta_lake_storage_size" {
  description = "Storage size for Delta Lake (in GB)"
  type        = number
  default     = 50
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

variable "container_registry" {
  description = "Container registry URL"
  type        = string
}