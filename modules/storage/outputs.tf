output "minio_service_name" {
  description = "MinIO service name"
  value       = "minio"
}

output "minio_service_namespace" {
  description = "MinIO service namespace"
  value       = kubernetes_namespace.storage.metadata[0].name
}

output "minio_endpoint" {
  description = "MinIO service endpoint"
  value       = "http://minio.${kubernetes_namespace.storage.metadata[0].name}.svc.cluster.local:9000"
}

output "delta_lake_storage_account_name" {
  description = "Delta Lake storage account name"
  value       = azurerm_storage_account.delta_lake.name
}

output "delta_lake_storage_container_name" {
  description = "Delta Lake storage container name"
  value       = azurerm_storage_container.delta_lake.name
}

output "storage_namespace" {
  description = "Storage namespace"
  value       = kubernetes_namespace.storage.metadata[0].name
}