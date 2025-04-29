# Namespace for compute components
resource "kubernetes_namespace" "compute" {
  metadata {
    name = "compute"
  }
}

# Deploy LLM (SLM, Cloud)
resource "kubernetes_deployment" "slm_model" {
  metadata {
    name      = "slm-model"
    namespace = kubernetes_namespace.compute.metadata[0].name
  }
  
  spec {
    replicas = 1
    
    selector {
      match_labels = {
        app = "slm-model"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "slm-model"
        }
      }
      
      spec {
        container {
          name  = "slm-model"
          image = "${var.container_registry}/slm-model:latest"
          
          port {
            container_port = 8080
          }
          
          resources {
            limits = {
              cpu    = "4"
              memory = "16Gi"
            }
            requests = {
              cpu    = "2"
              memory = "8Gi"
            }
          }
        }
        
        node_selector = {
          "beta.kubernetes.io/instance-type" = "Standard_NC6s_v3"  # GPU-enabled VM
        }
      }
    }
  }
  
  depends_on = [
    kubernetes_namespace.compute
  ]
}

# Service for SLM Model
resource "kubernetes_service" "slm_model" {
  metadata {
    name      = "slm-model"
    namespace = kubernetes_namespace.compute.metadata[0].name
  }
  
  spec {
    selector = {
      app = "slm-model"
    }
    
    port {
      port        = 8080
      target_port = 8080
    }
    
    type = "ClusterIP"
  }
  
  depends_on = [
    kubernetes_deployment.slm_model
  ]
}

# Deploy LLM (Cloud)
resource "kubernetes_deployment" "llm_model" {
  metadata {
    name      = "llm-model"
    namespace = kubernetes_namespace.compute.metadata[0].name
  }
  
  spec {
    replicas = 1
    
    selector {
      match_labels = {
        app = "llm-model"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "llm-model"
        }
      }
      
      spec {
        container {
          name  = "llm-model"
          image = "${var.container_registry}/llm-model:latest"
          
          port {
            container_port = 8080
          }
          
          env {
            name  = "AZURE_OPENAI_ENDPOINT"
            value = var.azure_openai_endpoint
          }
          
          env {
            name  = "AZURE_OPENAI_API_KEY"
            value = var.azure_openai_api_key
          }
          
          resources {
            limits = {
              cpu    = "2"
              memory = "4Gi"
            }
            requests = {
              cpu    = "1"
              memory = "2Gi"
            }
          }
        }
      }
    }
  }
  
  depends_on = [
    kubernetes_namespace.compute
  ]
}

# Service for LLM Model
resource "kubernetes_service" "llm_model" {
  metadata {
    name      = "llm-model"
    namespace = kubernetes_namespace.compute.metadata[0].name
  }
  
  spec {
    selector = {
      app = "llm-model"
    }
    
    port {
      port        = 8080
      target_port = 8080
    }
    
    type = "ClusterIP"
  }
  
  depends_on = [
    kubernetes_deployment.llm_model
  ]
}

# Deploy Node.js Backend
resource "kubernetes_deployment" "node_backend" {
  metadata {
    name      = "node-backend"
    namespace = kubernetes_namespace.compute.metadata[0].name
  }
  
  spec {
    replicas = 2
    
    selector {
      match_labels = {
        app = "node-backend"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "node-backend"
        }
      }
      
      spec {
        container {
          name  = "node-backend"
          image = "${var.container_registry}/node-backend:latest"
          
          port {
            container_port = 3000
          }
          
          env {
            name  = "MINIO_ENDPOINT"
            value = var.minio_endpoint
          }
          
          env {
            name  = "QDRANT_ENDPOINT"
            value = var.qdrant_service_endpoint
          }
          
          env {
            name  = "TRINO_ENDPOINT"
            value = var.trino_service_endpoint
          }
          
          env {
            name  = "SLM_MODEL_ENDPOINT"
            value = "http://slm-model.${kubernetes_namespace.compute.metadata[0].name}.svc.cluster.local:8080"
          }
          
          env {
            name  = "LLM_MODEL_ENDPOINT"
            value = "http://llm-model.${kubernetes_namespace.compute.metadata[0].name}.svc.cluster.local:8080"
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
    kubernetes_service.slm_model,
    kubernetes_service.llm_model
  ]
}

# Service for Node.js Backend
resource "kubernetes_service" "node_backend" {
  metadata {
    name      = "node-backend"
    namespace = kubernetes_namespace.compute.metadata[0].name
  }
  
  spec {
    selector = {
      app = "node-backend"
    }
    
    port {
      port        = 3000
      target_port = 3000
    }
    
    type = "ClusterIP"
  }
  
  depends_on = [
    kubernetes_deployment.node_backend
  ]
}

# Deploy Flask Backend
resource "kubernetes_deployment" "flask_backend" {
  metadata {
    name      = "flask-backend"
    namespace = kubernetes_namespace.compute.metadata[0].name
  }
  
  spec {
    replicas = 2
    
    selector {
      match_labels = {
        app = "flask-backend"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "flask-backend"
        }
      }
      
      spec {
        container {
          name  = "flask-backend"
          image = "${var.container_registry}/flask-backend:latest"
          
          port {
            container_port = 5000
          }
          
          env {
            name  = "MINIO_ENDPOINT"
            value = var.minio_endpoint
          }
          
          env {
            name  = "QDRANT_ENDPOINT"
            value = var.qdrant_service_endpoint
          }
          
          env {
            name  = "TRINO_ENDPOINT"
            value = var.trino_service_endpoint
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
    kubernetes_namespace.compute
  ]
}

# Service for Flask Backend
resource "kubernetes_service" "flask_backend" {
  metadata {
    name      = "flask-backend"
    namespace = kubernetes_namespace.compute.metadata[0].name
  }
  
  spec {
    selector = {
      app = "flask-backend"
    }
    
    port {
      port        = 5000
      target_port = 5000
    }
    
    type = "ClusterIP"
  }
  
  depends_on = [
    kubernetes_deployment.flask_backend
  ]
}