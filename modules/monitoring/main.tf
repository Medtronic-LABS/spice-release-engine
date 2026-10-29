resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "prometheus" {
  name             = "prometheus"
  namespace        = kubernetes_namespace.this.metadata[0].name
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = var.prometheus_stack_version
  create_namespace = false
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          replicas               = var.prometheus_replicas
          retention              = var.prometheus_retention
          storageSpec = var.prometheus_storage_size != "" ? {
            volumeClaimTemplate = {
              spec = {
                storageClassName = var.prometheus_storage_class != "" ? var.prometheus_storage_class : var.storage_class
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = var.prometheus_storage_size
                  }
                }
              }
            }
          } : {}
          resources = var.prometheus_resources
        }
      }
      grafana = {
        enabled  = var.grafana_enabled
        replicas = var.grafana_replicas
        adminPassword = var.grafana_admin_password
        persistence = {
          enabled          = var.grafana_storage_size != ""
          storageClassName = var.grafana_storage_class != "" ? var.grafana_storage_class : var.storage_class
          size             = var.grafana_storage_size != "" ? var.grafana_storage_size : "10Gi"
        }
        service = {
          type = var.grafana_service_type
        }
        ingress = {
          enabled          = var.grafana_ingress_enabled
          ingressClassName = var.ingress_class_name
          annotations = merge(
            {
              "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
              "alb.ingress.kubernetes.io/target-type"  = "ip"
              "alb.ingress.kubernetes.io/group.name"   = var.grafana_ingress_group_name
              "alb.ingress.kubernetes.io/listen-ports"  = var.grafana_certificate_arn != "" ? "[{\"HTTPS\":443},{\"HTTP\":80}]" : "[{\"HTTP\":80}]"
              "alb.ingress.kubernetes.io/success-codes" = "200,302"
            },
            var.grafana_certificate_arn != "" ? {
              "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
              "alb.ingress.kubernetes.io/certificate-arn"  = var.grafana_certificate_arn
              "alb.ingress.kubernetes.io/ssl-policy"       = "ELBSecurityPolicy-TLS13-1-2-2021-06"
            } : {},
            var.grafana_ingress_annotations,
          )
          hosts = var.grafana_domain != "" ? [var.grafana_domain] : []
          path  = "/"
        }
        additionalDataSources = var.loki_enabled ? [
          {
            name      = "Loki"
            type      = "loki"
            url       = "http://loki-gateway.${var.namespace}.svc.cluster.local"
            access    = "proxy"
            isDefault = false
          }
        ] : []
      }
      alertmanager = {
        enabled = var.alertmanager_enabled
        alertmanagerSpec = {
          replicas = var.alertmanager_replicas
        }
      }
    })
  ]
}

resource "helm_release" "loki" {
  count = var.loki_enabled ? 1 : 0

  name             = "loki"
  namespace        = kubernetes_namespace.this.metadata[0].name
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  version          = var.loki_version
  create_namespace = false
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      deploymentMode = "SingleBinary"
      loki = {
        auth_enabled = false
        commonConfig = {
          replication_factor = 1
        }
        storage = {
          type = "filesystem"
        }
        schemaConfig = {
          configs = [
            {
              from         = "2024-01-01"
              store        = "tsdb"
              object_store = "filesystem"
              schema       = "v13"
              index = {
                prefix = "index_"
                period = "24h"
              }
            }
          ]
        }
      }
      singleBinary = {
        replicas = 1
        persistence = {
          enabled      = var.loki_storage_size != ""
          storageClass = var.storage_class
          size             = var.loki_storage_size != "" ? var.loki_storage_size : "10Gi"
        }
      }
      gateway = {
        enabled = true
      }
      read      = { replicas = 0 }
      write     = { replicas = 0 }
      backend   = { replicas = 0 }
      chunksCache  = { enabled = false }
      resultsCache = { enabled = false }
    })
  ]

  depends_on = [helm_release.prometheus]
}

resource "helm_release" "promtail" {
  count = var.loki_enabled ? 1 : 0

  name             = "promtail"
  namespace        = kubernetes_namespace.this.metadata[0].name
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "promtail"
  version          = var.promtail_version
  create_namespace = false
  wait             = true
  timeout          = 300

  values = [
    yamlencode({
      config = {
        clients = [
          {
            url = "http://loki-gateway.${var.namespace}.svc.cluster.local/loki/api/v1/push"
          }
        ]
      }
    })
  ]

  depends_on = [helm_release.loki]
}
