# Namespace for agent orchestration components
resource "kubernetes_namespace" "agent_orchestration" {
  metadata {
    name = "agent-orchestration"
  }
}

# Deploy MS Bot Framework SDK service
resource "kubernetes_deployment" "ms_bot_framework" {
  metadata {
    name      = "ms-bot-framework"
    namespace = kubernetes_namespace.agent_orchestration.metadata[0].name
  }
  
  spec {
    replicas = 1
    
    selector {
      match_labels = {
        app = "ms-bot-framework"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "ms-bot-framework"
        }
      }
      
      spec {
        container {
          name  = "ms-bot-framework"
          image = "${var.container_registry}/ms-bot-framework:latest"
          
          port {
            container_port = 3978
          }
          
          env {
            name  = "MicrosoftAppId"
            value = var.microsoft_app_id
          }
          
          env {
            name  = "MicrosoftAppPassword"
            value = var.microsoft_app_password
          }
          
          resources {
            limits = {
              cpu    = "1"
              memory = "2Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
        }
      }
    }
  }
  
  depends_on = [
    kubernetes_namespace.agent_orchestration
  ]
}

# Service for MS Bot Framework
resource "kubernetes_service" "ms_bot_framework" {
  metadata {
    name      = "ms-bot-framework"
    namespace = kubernetes_namespace.agent_orchestration.metadata[0].name
  }
  
  spec {
    selector = {
      app = "ms-bot-framework"
    }
    
    port {
      port        = 3978
      target_port = 3978
    }
    
    type = "ClusterIP"
  }
  
  depends_on = [
    kubernetes_deployment.ms_bot_framework
  ]
}

# Deploy N8N for orchestration if enabled
resource "kubernetes_deployment" "n8n" {
  count = var.n8n_enabled ? 1 : 0
  
  metadata {
    name      = "n8n"
    namespace = kubernetes_namespace.agent_orchestration.metadata[0].name
  }
  
  spec {
    replicas = 1
    
    selector {
      match_labels = {
        app = "n8n"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "n8n"
        }
      }
      
      spec {
        container {
          name  = "n8n"
          image = "n8nio/n8n:latest"
          
          port {
            container_port = 5678
          }
          
          env {
            name  = "N8N_PORT"
            value = "5678"
          }
          
          env {
            name  = "N8N_PROTOCOL"
            value = "http"
          }
          
          env {
            name  = "N8N_HOST"
            value = "n8n.${kubernetes_namespace.agent_orchestration.metadata[0].name}.svc.cluster.local"
          }
          
          resources {
            limits = {
              cpu    = "1"
              memory = "2Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
        }
      }
    }
  }
  
  depends_on = [
    kubernetes_namespace.agent_orchestration
  ]
}

# Service for N8N
resource "kubernetes_service" "n8n" {
  count = var.n8n_enabled ? 1 : 0
  
  metadata {
    name      = "n8n"
    namespace = kubernetes_namespace.agent_orchestration.metadata[0].name
  }
  
  spec {
    selector = {
      app = "n8n"
    }
    
    port {
      port        = 5678
      target_port = 5678
    }
    
    type = "ClusterIP"
  }
  
  depends_on = [
    kubernetes_deployment.n8n
  ]
}

# Deploy LangChain for agent orchestration if enabled
resource "kubernetes_deployment" "langchain" {
  count = var.langchain_enabled ? 1 : 0
  
  metadata {
    name      = "langchain"
    namespace = kubernetes_namespace.agent_orchestration.metadata[0].name
  }
  
  spec {
    replicas = 1
    
    selector {
      match_labels = {
        app = "langchain"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "langchain"
        }
      }
      
      spec {
        container {
          name  = "langchain"
          image = "${var.container_registry}/langchain-service:latest"
          
          port {
            container_port = 8000
          }
          
          env {
            name  = "QDRANT_URL"
            value = var.qdrant_service_endpoint
          }
          
          env {
            name  = "EMBEDDING_MODEL_URL"
            value = var.embedding_model_service_endpoint
          }
          
          resources {
            limits = {
              cpu    = "1"
              memory = "2Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
        }
      }
    }
  }
  
  depends_on = [
    kubernetes_namespace.agent_orchestration
  ]
}

# Service for LangChain
resource "kubernetes_service" "langchain" {
  count = var.langchain_enabled ? 1 : 0
  
  metadata {
    name      = "langchain"
    namespace = kubernetes_namespace.agent_orchestration.metadata[0].name
  }
  
  spec {
    selector = {
      app = "langchain"
    }
    
    port {
      port        = 8000
      target_port = 8000
    }
    
    type = "ClusterIP"
  }
  
  depends_on = [
    kubernetes_deployment.langchain
  ]
}

# Deploy A2A Protocol service
resource "kubernetes_deployment" "a2a_protocol" {
  metadata {
    name      = "a2a-protocol"
    namespace = kubernetes_namespace.agent_orchestration.metadata[0].name
  }
  
  spec {
    replicas = 1
    
    selector {
      match_labels = {
        app = "a2a-protocol"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "a2a-protocol"
        }
      }
      
      spec {
        container {
          name  = "a2a-protocol"
          image = "${var.container_registry}/a2a-protocol:latest"
          
          port {
            container_port = 8080
          }
          
          resources {
            limits = {
              cpu    = "1"
              memory = "2Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
        }
      }
    }
  }
  
  depends_on = [
    kubernetes_namespace.agent_orchestration
  ]
}

# Service for A2A Protocol
resource "kubernetes_service" "a2a_protocol" {
  metadata {
    name      = "a2a-protocol"
    namespace = kubernetes_namespace.agent_orchestration.metadata[0].name
  }
  
  spec {
    selector = {
      app = "a2a-protocol"
    }
    
    port {
      port        = 8080
      target_port = 8080
    }
    
    type = "ClusterIP"
  }
  
  depends_on = [
    kubernetes_deployment.a2a_protocol
  ]
}

# Deploy MCP Server
resource "kubernetes_deployment" "mcp_server" {
  metadata {
    name      = "mcp-server"
    namespace = kubernetes_namespace.agent_orchestration.metadata[0].name
  }
  
  spec {
    replicas = 1
    
    selector {
      match_labels = {
        app = "mcp-server"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "mcp-server"
        }
      }
      
      spec {
        container {
          name  = "mcp-server"
          image = "context7-mcp:latest"  # Using Context7 MCP as shown in documentation
          
          port {
            container_port = 3000
          }
          
          resources {
            limits = {
              cpu    = "1"
              memory = "2Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
        }
      }
    }
  }
  
  depends_on = [
    kubernetes_namespace.agent_orchestration
  ]
}

# Service for MCP Server
resource "kubernetes_service" "mcp_server" {
  metadata {
    name      = "mcp-server"
    namespace = kubernetes_namespace.agent_orchestration.metadata[0].name
  }
  
  spec {
    selector = {
      app = "mcp-server"
    }
    
    port {
      port        = 3000
      target_port = 3000
    }
    
    type = "ClusterIP"
  }
  
  depends_on = [
    kubernetes_deployment.mcp_server
  ]
}