#!/bin/bash

# Script para instalar e configurar Prometheus + Grafana + AlertManager

set -e

NAMESPACE="monitoring"
CLUSTER_NAME="${1:-tech-challenge-cluster}"
AWS_REGION="${2:-us-east-1}"

echo "📊 Instalando stack de monitoramento..."

# 1. Criar namespace
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# 2. Adicionar Helm repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# 3. Instalar kube-prometheus-stack (Prometheus + AlertManager + Node Exporter)
cat > /tmp/prometheus-values.yaml <<EOF
prometheus:
  prometheusSpec:
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi
    retention: 30d
    additionalScrapeConfigs:
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: \$1:\$2
            target_label: __address__

alertmanager:
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 5Gi
  config:
    global:
      resolve_timeout: 5m
    route:
      group_by: ['alertname', 'cluster', 'service']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 12h
      receiver: 'default'
      routes:
        - match:
            severity: critical
          receiver: 'critical'
          continue: true
    receivers:
      - name: 'default'
        webhook_configs:
          - url: 'http://localhost:5001/'
      - name: 'critical'
        webhook_configs:
          - url: 'http://localhost:5001/'
        slack_configs:
          - api_url: '' # Configure com sua webhook do Slack
            channel: '#alerts'
            title: 'Critical Alert'

grafana:
  adminPassword: 'admin123'
  persistence:
    enabled: true
    size: 10Gi
  datasources:
    datasources.yaml:
      apiVersion: 1
      datasources:
        - name: Prometheus
          type: prometheus
          url: http://prometheus-operated:9090
          access: proxy
          isDefault: true
        - name: CloudWatch
          type: cloudwatch
          jsonData:
            authType: default
            defaultRegion: $AWS_REGION

EOF

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace $NAMESPACE \
  --values /tmp/prometheus-values.yaml

# 4. Criar ConfigMap para dashboard customizado
cat > /tmp/custom-dashboard.yaml <<'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: custom-dashboard
  namespace: monitoring
data:
  dashboard.json: |
    {
      "dashboard": {
        "title": "Tech Challenge - Application Metrics",
        "panels": [
          {
            "title": "API Request Rate",
            "targets": [{"expr": "rate(http_requests_total[5m])"}]
          },
          {
            "title": "API Latency (p95)",
            "targets": [{"expr": "histogram_quantile(0.95, http_server_requests_seconds_bucket)"}]
          },
          {
            "title": "API Error Rate",
            "targets": [{"expr": "rate(http_requests_total{status=~'5..'}[5m])"}]
          },
          {
            "title": "Pod CPU Usage",
            "targets": [{"expr": "sum(rate(container_cpu_usage_seconds_total[5m])) by (pod)"}]
          },
          {
            "title": "Pod Memory Usage",
            "targets": [{"expr": "sum(container_memory_usage_bytes) by (pod)"}]
          },
          {
            "title": "Database Connections",
            "targets": [{"expr": "pg_stat_activity_count"}]
          },
          {
            "title": "RDS CPU Usage",
            "targets": [{"expr": "aws_rds_cpu_utilization"}]
          },
          {
            "title": "Lambda Invocations",
            "targets": [{"expr": "rate(aws_lambda_invocations[5m])"}]
          },
          {
            "title": "Lambda Errors",
            "targets": [{"expr": "rate(aws_lambda_errors[5m])"}]
          },
          {
            "title": "Health Check Status",
            "targets": [{"expr": "up"}]
          }
        ]
      }
    }
YAML

kubectl apply -f /tmp/custom-dashboard.yaml

# 5. Criar NetworkPolicy para monitoramento
cat > /tmp/monitoring-netpol.yaml <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-monitoring
  namespace: monitoring
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    - namespaceSelector:
        matchLabels:
          name: tech-challenge
    ports:
    - protocol: TCP
      port: 9090
    - protocol: TCP
      port: 9093
    - protocol: TCP
      port: 3000
    - protocol: TCP
      port: 9100
YAML

kubectl apply -f /tmp/monitoring-netpol.yaml

# 6. Port forward para acessar Grafana e Prometheus
echo ""
echo "✅ Stack de monitoramento instalada com sucesso!"
echo ""
echo "📊 Para acessar Grafana:"
echo "   kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "   URL: http://localhost:3000"
echo "   Usuário: admin"
echo "   Senha: admin123"
echo ""
echo "📈 Para acessar Prometheus:"
echo "   kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090"
echo "   URL: http://localhost:9090"
echo ""
echo "🚨 Para acessar AlertManager:"
echo "   kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093"
echo "   URL: http://localhost:9093"
echo ""

