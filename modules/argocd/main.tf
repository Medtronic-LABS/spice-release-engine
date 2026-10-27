resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "this" {
  name             = "argocd"
  namespace        = kubernetes_namespace.this.metadata[0].name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_version
  create_namespace = false
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      global = {
        domain = var.argocd_domain
      }
      server = {
        replicas = var.server_replicas
        service = {
          type = var.service_type
        }
        ingress = {
          enabled          = var.ingress_enabled
          ingressClassName = var.ingress_class_name
          annotations = merge(
            {
              "alb.ingress.kubernetes.io/scheme"       = "internet-facing"
              "alb.ingress.kubernetes.io/target-type"   = "ip"
              "alb.ingress.kubernetes.io/group.name"    = "spice-argocd"
              "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
              "alb.ingress.kubernetes.io/listen-ports"  = var.certificate_arn != "" ? "[{\"HTTPS\":443},{\"HTTP\":80}]" : "[{\"HTTP\":80}]"
              "alb.ingress.kubernetes.io/success-codes" = "200,302"
            },
            var.certificate_arn != "" ? {
              "alb.ingress.kubernetes.io/ssl-redirect"   = "443"
              "alb.ingress.kubernetes.io/certificate-arn" = var.certificate_arn
              "alb.ingress.kubernetes.io/ssl-policy"      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
            } : {},
            var.ingress_annotations,
          )
          hosts = var.argocd_domain != "" ? [var.argocd_domain] : []
        }
      }
      controller = {
        replicas = var.controller_replicas
      }
      repoServer = {
        replicas = var.repo_server_replicas
      }
      applicationSet = {
        replicas = var.appset_replicas
      }
      configs = {
        params = {
          "server.insecure" = var.server_insecure
        }
      }
    })
  ]
}
