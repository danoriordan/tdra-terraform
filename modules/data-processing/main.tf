# Namespace for data processing components
resource "kubernetes_namespace" "data_processing" {
  metadata {
    name = "data-processing"
  }
}

# Persistent volume claims for Qdrant vector store
resource "kubernetes_persistent_volume_claim" "qdrant_pvc" {
  metadata {
    name      = "qdrant-data"
    namespace = kubernetes_namespace.data_processing.metadata[0].name
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "${var.qdrant_storage_size}Gi"
      }
    }
    storage_class_name = "azure-disk-standard"
  }
}

# Persistent volume claims for RDF Graph DB
resource "kubernetes_persistent_volume_claim" "rdf_graph_pvc" {
  metadata {
    name      = "rdf-graph-data"
    namespace = kubernetes_namespace.data_processing.metadata[0].name
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "${var.rdf_graph_storage_size}Gi"
      }
    }
    storage_class_name = "azure-disk-standard"
  }
}

# Deploy Trino for data processing
resource "kubernetes_deployment" "trino" {
  metadata {
    name      = "trino"
    namespace = kubernetes_namespace.data_processing.metadata[0].name
  }
  
  spec {
    replicas = 1
    
    selector {
      match_labels = {
        app = "trino"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "trino"
        }
      }
      
      spec {
        container {
          name  = "trino"
          image = "trinodb/trino:latest"
          
          port {
            container_port = 8080
          }
          
          env {
            name  = "MINIO_ENDPOINT"
            value = var.minio_endpoint
          }
          
          resources {
            limits = {
              cpu    = var.trino_cpu_limit
              memory = var.trino_memory_limit
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
    kubernetes_namespace.data_processing
  ]
}

# Service for Trino
resource "kubernetes_service" "trino" {
  metadata {
    name      = "trino"
    namespace = kubernetes_namespace.data_processing.metadata[0].name
  }
  
  spec {
    selector = {
      app = "trino"
    }
    
    port {
      port        = 8080
      target_port = 8080
    }
    
    type = "ClusterIP"
  }
  
  depends_on = [
    kubernetes_deployment.trino
  ]
}

# Deploy Qdrant vector database
resource "kubernetes_deployment" "qdrant" {
  metadata {
    name      = "qdrant"
    namespace = kubernetes_namespace.data_processing.metadata[0].name
  }
  
  spec {
    replicas = 1
    
    selector {
      match_labels = {
        app = "qdrant"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "qdrant"
        }
      }
      
      spec {
        container {
          name  = "qdrant"
          image = "qdrant/qdrant:latest"
          
          port {
            container_port = 6333  # REST API
          }
          
          port {
            container_port = 6334  # gRPC
          }
          
          volume_mount {
            name       = "qdrant-data"
            mount_path = "/qdrant/storage"
          }
          
          resources {
            limits = {
              cpu    = "2"
              memory = "4Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
        }
        
        volume {
          name = "qdrant-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.qdrant_pvc.metadata[0].name
          }
        }
      }
    }
  }
  
  depends_on = [
    kubernetes_persistent_volume_claim.qdrant_pvc
  ]
}

# Service for Qdrant
resource "kubernetes_service" "qdrant" {
  metadata {
    name      = "qdrant"
    namespace = kubernetes_namespace.data_processing.metadata[0].name
  }
  
  spec {
    selector = {
      app = "qdrant"
    }
    
    port {
      name        = "rest"
      port        = 6333
      target_port = 6333
    }
    
    port {
      name        = "grpc"
      port        = 6334
      target_port = 6334
    }
    
    type = "ClusterIP"
  }
  
  depends_on = [
    kubernetes_deployment.qdrant
  ]
}

# Deploy RDF Graph Database
resource "kubernetes_deployment" "rdf_graph_db" {
  metadata {
    name      = "rdf-graph-db"
    namespace = kubernetes_namespace.data_processing.metadata[0].name
  }
  
  spec {
    replicas = 1
    
    selector {
      match_labels = {
        app = "rdf-graph-db"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "rdf-graph-db"
        }
      }
      
      spec {
        container {
          name  = "rdf-graph-db"
          image = "openlink/virtuoso-opensource-7:latest"
          
          port {
            container_port = 8890  # HTTP
          }
          
          port {
            container_port = 1111  # SQL
          }
          
          volume_mount {
            name       = "rdf-graph-data"
            mount_path = "/database"
          }
          
          resources {
            limits = {
              cpu    = "2"
              memory = "4Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
          
          env {
            name  = "DBA_PASSWORD"
            value = "dba"  # In production, use a secret
          }
        }
        
        volume {
          name = "rdf-graph-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.rdf_graph_pvc.metadata[0].name
          }
        }
      }
    }
  }
  
  depends_on = [
    kubernetes_persistent_volume_claim.rdf_graph_pvc
  ]
}

# Service for RDF Graph DB
resource "kubernetes_service" "rdf_graph_db" {
  metadata {
    name      = "rdf-graph-db"
    namespace = kubernetes_namespace.data_processing.metadata[0].name
  }
  
  spec {
    selector = {
      app = "rdf-graph-db"
    }
    
    port {
      name        = "http"
      port        = 8890
      target_port = 8890
    }
    
    port {
      name        = "sql"
      port        = 1111
      target_port = 1111
    }
    
    type = "ClusterIP"
  }
  
  depends_on = [
    kubernetes_deployment.rdf_graph_db
  ]
}

# Deploy parsing, chunking, indexing and embedding service
resource "kubernetes_deployment" "document_processor" {
  metadata {
    name      = "document-processor"
    namespace = kubernetes_namespace.data_processing.metadata[0].name
  }
  
  spec {
    replicas = 2
    
    selector {
      match_labels = {
        app = "document-processor"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "document-processor"
        }
      }
      
      spec {
        container {
          name  = "document-processor"
          image = "${var.container_registry}/document-processor:latest"
          
          port {
            container_port = 8000
          }
          
          env {
            name  = "MINIO_ENDPOINT"
            value = var.minio_endpoint
          }
          
          env {
            name  = "QDRANT_ENDPOINT"
            value = "http://qdrant.${kubernetes_namespace.data_processing.metadata[0].name}.svc.cluster.local:6333"
          }
          
          env {
            name  = "RDF_GRAPH_ENDPOINT"
            value = "http://rdf-graph-db.${kubernetes_namespace.data_processing.metadata[0].name}.svc.cluster.local:8890"
          }
          
          resources {
            limits = {
              cpu    = "2"
              memory = "4Gi"
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
    kubernetes_service.qdrant,
    kubernetes_service.rdf_graph_db
  ]
}

# Service for document processor
resource "kubernetes_service" "document_processor" {
  metadata {
    name      = "document-processor"
    namespace = kubernetes_namespace.data_processing.metadata[0].name
  }
  
  spec {
    selector = {
      app = "document-processor"
    }
    
    port {
      port        = 8000
      target_port = 8000
    }
    
    type = "ClusterIP"
  }
  
  depends_on = [
    kubernetes_deployment.document_processor
  ]
}

# Deploy embedding model service
resource "kubernetes_deployment" "embedding_model" {
  metadata {
    name      = "embedding-model"
    namespace = kubernetes_namespace.data_processing.metadata[0].name
  }
  
  spec {
    replicas = 1
    
    selector {
      match_labels = {
        app = "embedding-model"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "embedding-model"
        }
      }
      
      spec {
        container {
          name  = "embedding-model"
          image = "${var.container_registry}/embedding-model:latest"
          
          port {
            container_port = 8080
          }
          
          resources {
            limits = {
              cpu    = "4"
              memory = "8Gi"
            }
            requests = {
              cpu    = "1"
              memory = "2Gi"
            }
          }
          
          # If using Azure AI, connect to the services
          dynamic "env" {
            for_each = var.azure_ai_services_enabled ? [1] : []
            content {
              name  = "AZURE_AI_ENDPOINT"
              value = var.azure_ai_endpoint
            }
          }
          
          dynamic "env" {
            for_each = var.azure_ai_services_enabled ? [1] : []
            content {
              name  = "AZURE_AI_KEY"
              value = var.azure_ai_key
            }
          }
        }
      }
    }
  }
  
  depends_on = [
    kubernetes_namespace.data_processing
  ]
}

# Service for embedding model
resource "kubernetes_service" "embedding_model" {
  metadata {
    name      = "embedding-model"
    namespace = kubernetes_namespace.data_processing.metadata[0].name
  }
  
  spec {
    selector = {
      app = "embedding-model"
    }
    
    port {
      port        = 8080
      target_port = 8080
    }
    
    type = "ClusterIP"
  }
  
  depends_on = [
    kubernetes_deployment.embedding_model
  ]
}