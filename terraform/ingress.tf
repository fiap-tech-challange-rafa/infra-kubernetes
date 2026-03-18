# Ingress Controller - Nginx
resource "helm_release" "nginx_ingress" {
  count            = var.enable_ingress ? 1 : 0
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.9.0"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.replicaCount"
    value = "2"
  }

  depends_on = [aws_eks_node_group.main]
}

# Monitoring - Prometheus
resource "helm_release" "prometheus" {
  count            = var.enable_monitoring ? 1 : 0
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "54.2.2"

  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          retention                = "7d"
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "50Gi"
                  }
                }
              }
            }
          }
          serviceMonitorSelectorNilUsesHelmValues = false
          ruleNamespaceSelectorNilUsesHelmValues  = false
        }
      }
      grafana = {
        adminPassword = "admin"
        persistence = {
          enabled = true
          size    = "10Gi"
        }
      }
    })
  ]

  depends_on = [aws_eks_node_group.main]
}
