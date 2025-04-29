# Data Platform Infrastructure on Azure Arc

This Terraform configuration deploys a complete data platform on Azure Arc Kubernetes, based on the provided architecture diagram. The infrastructure includes data storage, processing, agent orchestration, and compute components.

## Architecture Components

The infrastructure includes the following main components:

### Data Catalog / Federation
- **Trino**: Query engine for federated metadata access
- **RDF Graph DB**: For storing relationships and metadata

### Storage
- **MinIO**: Object storage for files (Bronze/Raw layer)
- **Delta Lake**: For structured data storage with ACID guarantees

### Document Processing
- **Parsing, Chunking, Indexing and Embedding**: For processing documents
- **N8N**: For orchestration of document processing workflows
- **Embedding Model**: For creating vector embeddings of text

### Agent Orchestration
- **MS Bot Framework SDK**: For building conversational agents
- **A2A Protocol**: For agent-to-agent communication
- **LangChain**: For constructing complex agent workflows
- **MCP Server**: Model Context Protocol server for LLM tools

### Compute
- **SLM Model**: Small Language Models running on-premises
- **LLM Model**: Large Language Models running in the cloud
- **Node.js & Flask**: Backend services

### Monitoring / Observability
- **Open Telemetry**: For distributed tracing
- **Grafana**: For visualization of metrics
- **Langsmith/Langfuse**: For LLM observability

## Prerequisites

1. Azure subscription
2. Terraform installed (version 1.0.0+)
3. Azure CLI installed and logged in
4. Kubernetes cluster (AKS) with Azure Arc connectivity
5. Storage account for Terraform state

## Setup Instructions

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Set Required Variables:**
   Create a `terraform.tfvars` file with the necessary variables:
   ```hcl
   prefix = "data-platform"
   resource_group_name = "data-platform-rg"
   location = "eastus"
   kubeconfig_path = "~/.kube/config"
   ```

3. **Plan the Deployment:**
   ```bash
   terraform plan -out=tfplan
   ```

4. **Apply the Configuration:**
   ```bash
   terraform apply tfplan
   ```

## Modules

### Storage
Manages MinIO and Delta Lake storage solutions.

### Data Processing
Deploys Qdrant vector store, RDF Graph DB, document processing services, and embedding models.

### Agent Orchestration
Sets up MS Bot Framework, LangChain, A2A Protocol, and MCP Server.

### Compute
Manages SLM/LLM models and backend services (Node.js, Flask).

### Infrastructure
Provisions monitoring and observability tools (Grafana, OpenTelemetry, Langsmith).

## Configuration Variables

See `variables.tf` for all available configuration options.

## Outputs

After deployment, Terraform will output all service endpoints, making it easy to connect to the various components.

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Azure Arc Integration

This deployment leverages Azure Arc for Kubernetes, allowing you to manage the containerized workloads through Azure portal, apply policies, and integrate with Azure Monitor.

## Extended Documentation

For more detailed documentation on each component:

1. [MinIO Documentation](https://min.io/docs/minio/container/index.html)
2. [Trino Documentation](https://trino.io/docs/current/)
3. [Qdrant Documentation](https://qdrant.tech/documentation/)
4. [Azure Arc Documentation](https://learn.microsoft.com/en-us/azure/azure-arc/)
5. [MCP Server Documentation](https://github.com/upstash/context7)