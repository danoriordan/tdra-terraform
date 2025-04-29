terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
  
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateaccount"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

# Data source to get the current client configuration
data "azurerm_client_config" "current" {}

# Resource Group for all resources
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Azure Arc enabled Kubernetes cluster
resource "azurerm_kubernetes_cluster" "arc_cluster" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.prefix}-aks"
  
  default_node_pool {
    name            = "default"
    node_count      = var.default_node_count
    vm_size         = var.default_node_size
    os_disk_size_gb = 50
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = var.tags
}

# Connect the cluster to Azure Arc
resource "azurerm_arc_kubernetes_cluster" "arc_k8s" {
  name                = "${var.prefix}-arc-k8s"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  
  identity {
    type = "SystemAssigned"
  }
  
  depends_on = [
    azurerm_kubernetes_cluster.arc_cluster
  ]
}

# Azure Container Registry for storing container images
resource "azurerm_container_registry" "acr" {
  name                = "${replace(var.prefix, "-", "")}acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
  admin_enabled       = true
  
  tags = var.tags
}

# Azure Monitor workspace for observability
resource "azurerm_log_analytics_workspace" "monitoring" {
  name                = "${var.prefix}-monitoring"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  tags = var.tags
}

# Azure Key Vault for secrets management
resource "azurerm_key_vault" "kv" {
  name                        = "${replace(var.prefix, "-", "")}kv"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  
  sku_name = "standard"
  
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    
    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge"
    ]
  }
  
  tags = var.tags
}

# Azure OpenAI Service for LLM capabilities
resource "azurerm_cognitive_account" "openai" {
  name                = "${var.prefix}-openai"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "OpenAI"
  sku_name            = "S0"

  tags = var.tags
}

# Azure AI Services for embedding and processing
resource "azurerm_cognitive_account" "ai_services" {
  name                = "${var.prefix}-ai-services"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "CognitiveServices"
  sku_name            = "S0"

  tags = var.tags
}

# Application Insights for monitoring
resource "azurerm_application_insights" "insights" {
  name                = "${var.prefix}-insights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"

  tags = var.tags
}

# Storage module
module "storage" {
  source = "./modules/storage"

  prefix              = var.prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = var.tags
  minio_storage_size  = var.minio_storage_size
  container_registry  = azurerm_container_registry.acr.login_server
  
  depends_on = [
    azurerm_kubernetes_cluster.arc_cluster
  ]
}

# Data Processing module
module "data_processing" {
  source = "./modules/data-processing"

  qdrant_storage_size         = var.qdrant_storage_size
  rdf_graph_storage_size      = var.rdf_graph_storage_size
  trino_cpu_limit             = var.trino_cpu_limit
  trino_memory_limit          = var.trino_memory_limit
  minio_endpoint              = module.storage.minio_endpoint
  container_registry          = azurerm_container_registry.acr.login_server
  azure_ai_services_enabled   = var.azure_ai_services_enabled
  azure_ai_endpoint           = azurerm_cognitive_account.ai_services.endpoint
  azure_ai_key                = azurerm_cognitive_account.ai_services.primary_access_key
  
  depends_on = [
    module.storage
  ]
}

# Agent Orchestration module
module "agent_orchestration" {
  source = "./modules/agent-orchestration"

  container_registry          = azurerm_container_registry.acr.login_server
  n8n_enabled                 = var.n8n_enabled
  langchain_enabled           = var.langchain_enabled
  qdrant_service_endpoint     = module.data_processing.qdrant_service_endpoint
  embedding_model_service_endpoint = module.data_processing.embedding_model_service_endpoint
  
  depends_on = [
    module.data_processing
  ]
}

# Compute module
module "compute" {
  source = "./modules/compute"

  container_registry      = azurerm_container_registry.acr.login_server
  minio_endpoint          = module.storage.minio_endpoint
  qdrant_service_endpoint = module.data_processing.qdrant_service_endpoint
  trino_service_endpoint  = module.data_processing.trino_service_endpoint
  azure_openai_endpoint   = azurerm_cognitive_account.openai.endpoint
  azure_openai_api_key    = azurerm_cognitive_account.openai.primary_access_key
  
  depends_on = [
    module.data_processing
  ]
}

# Infrastructure module
module "infrastructure" {
  source = "./modules/infrastructure"

  container_registry         = azurerm_container_registry.acr.login_server
  log_analytics_workspace_id = azurerm_log_analytics_workspace.monitoring.id
  application_insights_key   = azurerm_application_insights.insights.instrumentation_key
  
  depends_on = [
    azurerm_log_analytics_workspace.monitoring,
    azurerm_application_insights.insights
  ]
}