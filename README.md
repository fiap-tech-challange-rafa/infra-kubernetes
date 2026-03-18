# Infra Kubernetes - Provisionamento com Terraform

## 📋 Descrição

Este repositório contém a infraestrutura de Kubernetes (K8s) usando Terraform, provisionando um cluster completo e escalável na nuvem (AWS EKS, GCP GKE ou Azure AKS).

## 🛠️ Tecnologias Utilizadas

- **IaC**: Terraform 1.5+
- **Container Orchestration**: Kubernetes 1.27+
- **Cloud Providers**: AWS EKS / GCP GKE / Azure AKS
- **CI/CD**: GitHub Actions
- **Networking**: VPC, Subnets, Security Groups
- **Monitoring**: Prometheus, Grafana (opcional)
- **Ingress**: Nginx Ingress Controller

## 📁 Estrutura do Projeto

```
infra-kubernetes/
├── terraform/
│   ├── providers.tf            # Configuração de providers (AWS/GCP/Azure)
│   ├── variables.tf            # Declaração de variáveis
│   ├── outputs.tf              # Outputs (endpoints, etc)
│   ├── terraform.tfvars        # Valores das variáveis (gitignore)
│   ├── terraform.tfvars.example
│   ├── main.tf                 # Cluster K8s
│   ├── networking.tf           # VPC, Subnets, Security Groups
│   ├── iam.tf                  # IAM Roles, Service Accounts
│   ├── ingress.tf              # Nginx Ingress Controller
│   ├── monitoring.tf           # Prometheus, Grafana (opcional)
│   └── backend.tf              # Remote state (Terraform Cloud/S3)
├── k8s-manifests/
│   ├── namespaces.yaml
│   ├── deployments.yaml
│   ├── services.yaml
│   ├── configmaps.yaml
│   ├── secrets.yaml
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── rbac.yaml
│   └── monitoring/
│       ├── prometheus.yaml
│       ├── grafana.yaml
│       └── servicemonitor.yaml
├── .github/
│   └── workflows/
│       ├── plan.yml            # Terraform plan
│       ├── apply.yml           # Terraform apply
│       └── destroy.yml         # Terraform destroy (manual)
├── Dockerfile (opcional)
├── .gitignore
├── README.md
└── ARCHITECTURE.md
```

## 🚀 Como Executar Localmente

### Pré-requisitos
- Terraform 1.5+
- AWS CLI / gcloud / az CLI (conforme cloud provider)
- kubectl 1.27+
- Helm 3+ (opcional, para gerenciar charts)

### Passos

1. **Clone o repositório**
   ```bash
   git clone https://github.com/seu-usuario/infra-kubernetes.git
   cd infra-kubernetes/terraform
   ```

2. **Configure as variáveis**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edite terraform.tfvars com seus valores
   ```

3. **Inicialize Terraform**
   ```bash
   terraform init
   ```

4. **Valide a configuração**
   ```bash
   terraform fmt -recursive
   terraform validate
   ```

5. **Planeje a infraestrutura**
   ```bash
   terraform plan -out=tfplan
   ```

6. **Aplique a infraestrutura**
   ```bash
   terraform apply tfplan
   ```

7. **Configure kubectl**
   ```bash
   # AWS EKS
   aws eks update-kubeconfig --name <cluster-name> --region <region>

   # GCP GKE
   gcloud container clusters get-credentials <cluster-name> --zone <zone>

   # Azure AKS
   az aks get-credentials --resource-group <rg> --name <cluster-name>
   ```

8. **Aplique manifestos K8s**
   ```bash
   kubectl apply -f ../k8s-manifests/
   ```

## 📊 Arquitetura Provisionada

```
┌─────────────────────────────────────────────────────┐
│              Kubernetes Cluster (EKS/GKE/AKS)       │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │         Control Plane (Managed)              │  │
│  │  - API Server                                │  │
│  │  - Scheduler                                 │  │
│  │  - Controller Manager                        │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │         Worker Nodes (Auto-scaling)          │  │
│  │  ┌────────────┐  ┌────────────┐  ┌─────────┐│  │
│  │  │ Pod Group1 │  │ Pod Group2 │  │  ...    ││  │
│  │  │ (Tech App) │  │  (Ingress) │  │         ││  │
│  │  └────────────┘  └────────────┘  └─────────┘│  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │    Networking & Load Balancing               │  │
│  │  - Service: LoadBalancer / ClusterIP         │  │
│  │  - Ingress: Nginx                            │  │
│  │  - Network Policies                          │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │    Monitoring & Logging                      │  │
│  │  - Prometheus                                │  │
│  │  - Grafana                                   │  │
│  │  - CloudWatch / Stackdriver / Monitor        │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

## 🔄 Pipeline CI/CD

- **plan.yml**: Executa `terraform plan` em pull requests (validação)
- **apply.yml**: Executa `terraform apply` em merges para main (deploy automático)
- **destroy.yml**: Workflow manual para destruir infraestrutura

## 📝 Variáveis de Entrada (terraform.tfvars)

```hcl
# AWS
aws_region             = "us-east-1"
cluster_name           = "tech-challenge-cluster"
environment            = "production"
node_count             = 3
node_instance_type     = "t3.medium"
min_nodes              = 1
max_nodes              = 5

# Networking
vpc_cidr               = "10.0.0.0/16"
private_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnet_cidrs    = ["10.0.10.0/24", "10.0.11.0/24"]

# Tags
tags = {
  Environment = "production"
  Project     = "tech-challenge"
  ManagedBy   = "terraform"
}
```

## 📤 Outputs

Após aplicar, você receberá:
- Cluster endpoint
- Kubeconfig data
- Worker node IAM role ARN
- VPC ID e Subnet IDs
- Ingress IP/Hostname

## 🔒 Segurança

- ✅ VPC isolada com subnets privadas/públicas
- ✅ Security groups restritivos
- ✅ IAM roles e service accounts
- ✅ Network policies no K8s
- ✅ Secrets gerenciados via AWS Secrets Manager / GCP Secrets / Azure Key Vault
- ✅ RBAC configurado no cluster

## 📚 Documentação Adicional

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)

## 🤝 Contribuindo

1. Crie uma branch com sua feature: `git checkout -b feature/nova-infra`
2. Commit suas mudanças: `git commit -am 'Add nova feature'`
3. Push para a branch: `git push origin feature/nova-infra`
4. Abra um Pull Request

## 📄 Licença

MIT
