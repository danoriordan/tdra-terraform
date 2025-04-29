output "qdrant_service_name" {
  description = "Qdrant service name"
  value       = kubernetes_service.qdrant.metadata[0].name
}

output "qdrant_service_endpoint" {
  description = "Qdrant service endpoint"
  value       = "http://${kubernetes_service.qdrant.metadata[0].name}.${kubernetes_namespace.data_processing.metadata[0].name}.svc.cluster.local:6333"
}

output "trino_service_name" {
  description = "Trino service name"
  value       = kubernetes_service.trino.metadata[0].name
}

output "trino_service_endpoint" {
  description = "Trino service endpoint"
  value       = "http://${kubernetes_service.trino.metadata[0].name}.${kubernetes_namespace.data_processing.metadata[0].name}.svc.cluster.local:8080"
}

output "rdf_graph_db_service_name" {
  description = "RDF Graph DB service name"
  value       = kubernetes_service.rdf_graph_db.metadata[0].name
}

output "rdf_graph_db_service_endpoint" {
  description = "RDF Graph DB service endpoint"
  value       = "http://${kubernetes_service.rdf_graph_db.metadata[0].name}.${kubernetes_namespace.data_processing.metadata[0].name}.svc.cluster.local:8890"
}

output "document_processor_service_name" {
  description = "Document processor service name"
  value       = kubernetes_service.document_processor.metadata[0].name
}

output "document_processor_service_endpoint" {
  description = "Document processor service endpoint"
  value       = "http://${kubernetes_service.document_processor.metadata[0].name}.${kubernetes_namespace.data_processing.metadata[0].name}.svc.cluster.local:8000"
}

output "embedding_model_service_name" {
  description = "Embedding model service name"
  value       = kubernetes_service.embedding_model.metadata[0].name
}

output "embedding_model_service_endpoint" {
  description = "Embedding model service endpoint"
  value       = "http://${kubernetes_service.embedding_model.metadata[0].name}.${kubernetes_namespace.data_processing.metadata[0].name}.svc.cluster.local:8080"
}

output "data_processing_namespace" {
  description = "Data processing namespace"
  value       = kubernetes_namespace.data_processing.metadata[0].name
}