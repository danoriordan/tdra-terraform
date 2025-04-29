# Persistent volumes for storage components
resource "kubernetes_namespace" "storage" {
  metadata {
    name = "storage"
  }
}

# Persistent volume claims for MinIO object storage
resource "kubernetes_persistent_volume_claim" "minio_pvc" {
  metadata {
    name      = "minio-data"
    namespace = kubernetes_namespace.storage.metadata[0].name
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "${var.minio_storage_size}Gi"
      }
    }
    storage_class_name = "azure-disk-standard"
  }
}

# Persistent volume claims for Delta Lake
resource "kubernetes_persistent_volume_claim" "delta_lake_pvc" {
  metadata {
    name      = "delta-lake-data"
    namespace = kubernetes_namespace.storage.metadata[0].name
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "${var.delta_lake_storage_size}Gi"
      }
    }
    storage_class_name = "azure-disk-standard"
  }
}

# Deploy MinIO via Helm
resource "helm_release" "minio" {
  name       = "minio"
  namespace  = kubernetes_namespace.storage.metadata[0].name
  repository = "https://charts.min.io/"
  chart      = "minio"
  version    = "5.0.7"
  
  set {
    name  = "mode"
    value = "standalone"
  }
  
  set {
    name  = "persistence.enabled"
    value = "true"
  }
  
  set {
    name  = "persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.minio_pvc.metadata[0].name
  }
  
  set {
    name  = "resources.requests.memory"
    value = "1Gi"
  }
  
  set {
    name  = "resources.requests.cpu"
    value = "500m"
  }
  
  set {
    name  = "resources.limits.memory"
    value = "2Gi"
  }
  
  set {
    name  = "resources.limits.cpu"
    value = "1"
  }
  
  set {
    name  = "service.type"
    value = "ClusterIP"
  }
  
  set {
    name  = "rootUser"
    value = "minioadmin"
  }
  
  set {
    name  = "rootPassword"
    value = "minioadmin"  # In production, use a secret
  }
}

# Create Azure Storage Account for Delta Lake
resource "azurerm_storage_account" "delta_lake" {
  name                     = "${replace(var.prefix, "-", "")}deltalake"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  
  blob_properties {
    versioning_enabled = true
  }
  
  tags = var.tags
}

# Create Azure Storage Container for Delta Lake
resource "azurerm_storage_container" "delta_lake" {
  name                  = "deltalake"
  storage_account_name  = azurerm_storage_account.delta_lake.name
  container_access_type = "private"
}

# Deploy Delta Lake operator/connector
resource "kubernetes_deployment" "delta_lake_connector" {
  metadata {
    name      = "delta-lake-connector"
    namespace = kubernetes_namespace.storage.metadata[0].name
  }
  
  spec {
    replicas = 1
    
    selector {
      match_labels = {
        app = "delta-lake-connector"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "delta-lake-connector"
        }
      }
      
      spec {
        container {
          name  = "delta-lake-connector"
          image = "${var.container_registry}/delta-lake-connector:latest"
          
          env {
            name  = "AZURE_STORAGE_ACCOUNT"
            value = azurerm_storage_account.delta_lake.name
          }
          
          env {
            name  = "AZURE_STORAGE_ACCESS_KEY"
            value = azurerm_storage_account.delta_lake.primary_access_key
          }
          
          volume_mount {
            name       = "delta-lake-data"
            mount_path = "/data"
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
        
        volume {
          name = "delta-lake-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.delta_lake_pvc.metadata[0].name
          }
        }
      }
    }
  }
  
  depends_on = [
    kubernetes_persistent_volume_claim.delta_lake_pvc,
    azurerm_storage_container.delta_lake
  ]
}