# infra-kubernetes

Infraestrutura Kubernetes do Tech Challenge com Terraform na AWS (EKS).

## Recursos provisionados

- VPC, subnets publicas e privadas, NAT e rotas
- Cluster EKS e node group gerenciado
- IAM roles para cluster e nodes
- OIDC provider para IRSA
- Ingress NGINX via Helm (opcional)
- Stack Prometheus/Grafana via Helm (opcional)

## Estrutura

```text
infra-kubernetes/
├── terraform/
│   ├── providers.tf
│   ├── variables.tf
│   ├── networking.tf
│   ├── iam.tf
│   ├── main.tf
│   ├── ingress.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
└── .github/workflows/
    ├── plan.yml
    └── apply.yml
```

## Como usar

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Depois de aplicar:

```bash
aws eks update-kubeconfig --region <aws-region> --name <cluster-name>
kubectl get nodes
```

## Variaveis principais

- `aws_region`
- `cluster_name`
- `cluster_version`
- `vpc_cidr`
- `private_subnet_cidrs`
- `public_subnet_cidrs`
- `node_instance_type`
- `node_count`, `min_nodes`, `max_nodes`
- `enable_ingress`
- `enable_monitoring`

## CI/CD

- `plan.yml`: executa `terraform fmt`, `init`, `validate` e `plan` em PR
- `apply.yml`: executa `plan/apply` em push na branch `main` (quando arquivos em `terraform/**` mudam)
