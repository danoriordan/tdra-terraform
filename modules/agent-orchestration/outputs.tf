output "ms_bot_framework_service_name" {
  description = "MS Bot Framework service name"
  value       = kubernetes_service.ms_bot_framework.metadata[0].name
}

output "ms_bot_framework_service_endpoint" {
  description = "MS Bot Framework service endpoint"
  value       = "http://${kubernetes_service.ms_bot_framework.metadata[0].name}.${kubernetes_namespace.agent_orchestration.metadata[0].name}.svc.cluster.local:3978"
}

output "n8n_service_name" {
  description = "N8N service name"
  value       = var.n8n_enabled ? kubernetes_service.n8n[0].metadata[0].name : null
}

output "n8n_service_endpoint" {
  description = "N8N service endpoint"
  value       = var.n8n_enabled ? "http://${kubernetes_service.n8n[0].metadata[0].name}.${kubernetes_namespace.agent_orchestration.metadata[0].name}.svc.cluster.local:5678" : null
}

output "langchain_service_name" {
  description = "LangChain service name"
  value       = var.langchain_enabled ? kubernetes_service.langchain[0].metadata[0].name : null
}

output "langchain_service_endpoint" {
  description = "LangChain service endpoint"
  value       = var.langchain_enabled ? "http://${kubernetes_service.langchain[0].metadata[0].name}.${kubernetes_namespace.agent_orchestration.metadata[0].name}.svc.cluster.local:8000" : null
}

output "a2a_protocol_service_name" {
  description = "A2A Protocol service name"
  value       = kubernetes_service.a2a_protocol.metadata[0].name
}

output "a2a_protocol_service_endpoint" {
  description = "A2A Protocol service endpoint"
  value       = "http://${kubernetes_service.a2a_protocol.metadata[0].name}.${kubernetes_namespace.agent_orchestration.metadata[0].name}.svc.cluster.local:8080"
}

output "mcp_server_service_name" {
  description = "MCP Server service name"
  value       = kubernetes_service.mcp_server.metadata[0].name
}

output "mcp_server_service_endpoint" {
  description = "MCP Server service endpoint"
  value       = "http://${kubernetes_service.mcp_server.metadata[0].name}.${kubernetes_namespace.agent_orchestration.metadata[0].name}.svc.cluster.local:3000"
}

output "agent_orchestration_namespace" {
  description = "Agent orchestration namespace"
  value       = kubernetes_namespace.agent_orchestration.metadata[0].name
}