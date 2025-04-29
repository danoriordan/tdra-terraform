output "slm_model_service_name" {
  description = "SLM Model service name"
  value       = kubernetes_service.slm_model.metadata[0].name
}

output "slm_model_service_endpoint" {
  description = "SLM Model service endpoint"
  value       = "http://${kubernetes_service.slm_model.metadata[0].name}.${kubernetes_namespace.compute.metadata[0].name}.svc.cluster.local:8080"
}

output "llm_model_service_name" {
  description = "LLM Model service name"
  value       = kubernetes_service.llm_model.metadata[0].name
}

output "llm_model_service_endpoint" {
  description = "LLM Model service endpoint"
  value       = "http://${kubernetes_service.llm_model.metadata[0].name}.${kubernetes_namespace.compute.metadata[0].name}.svc.cluster.local:8080"
}

output "node_backend_service_name" {
  description = "Node.js Backend service name"
  value       = kubernetes_service.node_backend.metadata[0].name
}

output "node_backend_service_endpoint" {
  description = "Node.js Backend service endpoint"
  value       = "http://${kubernetes_service.node_backend.metadata[0].name}.${kubernetes_namespace.compute.metadata[0].name}.svc.cluster.local:3000"
}

output "flask_backend_service_name" {
  description = "Flask Backend service name"
  value       = kubernetes_service.flask_backend.metadata[0].name
}

output "flask_backend_service_endpoint" {
  description = "Flask Backend service endpoint"
  value       = "http://${kubernetes_service.flask_backend.metadata[0].name}.${kubernetes_namespace.compute.metadata[0].name}.svc.cluster.local:5000"
}

output "compute_namespace" {
  description = "Compute namespace"
  value       = kubernetes_namespace.compute.metadata[0].name
}