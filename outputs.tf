output "kubernetes_cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.arc_cluster.name
}

output "kubernetes_cluster_id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.arc_cluster.id
}

output "container_registry_login_server" {
  description = "Azure Container Registry login server"
  value       = azurerm_container_registry.acr.login_server
}

output "container_registry_admin_username" {
  description = "Azure Container Registry admin username"
  value       = azurerm_container_registry.acr.admin_username
}

output "container_registry_admin_password" {
  description = "Azure Container Registry admin password"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

output "key_vault_uri" {
  description = "Azure Key Vault URI"
  value       = azurerm_key_vault.kv.vault_uri
}

output "openai_endpoint" {
  description = "Azure OpenAI endpoint"
  value       = azurerm_cognitive_account.openai.endpoint
}

output "ai_services_endpoint" {
  description = "Azure AI Services endpoint"
  value       = azurerm_cognitive_account.ai_services.endpoint
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.insights.instrumentation_key
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.monitoring.id
}

# Storage module outputs
output "minio_endpoint" {
  description = "MinIO service endpoint"
  value       = module.storage.minio_endpoint
}

output "delta_lake_storage_account_name" {
  description = "Delta Lake storage account name"
  value       = module.storage.delta_lake_storage_account_name
}

# Data Processing module outputs
output "qdrant_service_endpoint" {
  description = "Qdrant service endpoint"
  value       = module.data_processing.qdrant_service_endpoint
}

output "trino_service_endpoint" {
  description = "Trino service endpoint"
  value       = module.data_processing.trino_service_endpoint
}

output "rdf_graph_db_service_endpoint" {
  description = "RDF Graph DB service endpoint"
  value       = module.data_processing.rdf_graph_db_service_endpoint
}

output "document_processor_service_endpoint" {
  description = "Document processor service endpoint"
  value       = module.data_processing.document_processor_service_endpoint
}

output "embedding_model_service_endpoint" {
  description = "Embedding model service endpoint"
  value       = module.data_processing.embedding_model_service_endpoint
}

# Agent Orchestration module outputs
output "ms_bot_framework_service_endpoint" {
  description = "MS Bot Framework service endpoint"
  value       = module.agent_orchestration.ms_bot_framework_service_endpoint
}

output "n8n_service_endpoint" {
  description = "N8N service endpoint"
  value       = module.agent_orchestration.n8n_service_endpoint
}

output "langchain_service_endpoint" {
  description = "LangChain service endpoint"
  value       = module.agent_orchestration.langchain_service_endpoint
}

output "a2a_protocol_service_endpoint" {
  description = "A2A Protocol service endpoint"
  value       = module.agent_orchestration.a2a_protocol_service_endpoint
}

output "mcp_server_service_endpoint" {
  description = "MCP Server service endpoint"
  value       = module.agent_orchestration.mcp_server_service_endpoint
}

# Compute module outputs
output "slm_model_service_endpoint" {
  description = "SLM Model service endpoint"
  value       = module.compute.slm_model_service_endpoint
}

output "llm_model_service_endpoint" {
  description = "LLM Model service endpoint"
  value       = module.compute.llm_model_service_endpoint
}

output "node_backend_service_endpoint" {
  description = "Node.js Backend service endpoint"
  value       = module.compute.node_backend_service_endpoint
}

output "flask_backend_service_endpoint" {
  description = "Flask Backend service endpoint"
  value       = module.compute.flask_backend_service_endpoint
}

# Infrastructure module outputs
output "grafana_service_endpoint" {
  description = "Grafana service endpoint"
  value       = module.infrastructure.grafana_service_endpoint
}

output "otel_collector_service_endpoint" {
  description = "OpenTelemetry Collector service endpoint"
  value       = module.infrastructure.otel_collector_service_endpoint
}

output "langsmith_service_endpoint" {
  description = "Langsmith service endpoint"
  value       = module.infrastructure.langsmith_service_endpoint
}

output "trino_virtualization_service_endpoint" {
  description = "Trino virtualization service endpoint"
  value       = module.infrastructure.trino_virtualization_service_endpoint
}

output "ollama_service_endpoint" {
  description = "Ollama service endpoint"
  value       = module.infrastructure.ollama_service_endpoint
}