module "this" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.0"

  cluster_name = var.cluster_name

  enable_v1_permissions           = true
  enable_pod_identity             = true
  create_pod_identity_association = true

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:${var.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = var.tags
}

resource "aws_iam_role_policy" "additional" {
  name = "KarpenterAdditionalPermissions"
  role = module.this.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowListInstanceProfiles"
        Effect   = "Allow"
        Action   = "iam:ListInstanceProfiles"
        Resource = "arn:${var.partition}:iam::${var.account_id}:instance-profile/*"
      },
      {
        Sid    = "AllowRunInstancesDryRun"
        Effect = "Allow"
        Action = [
          "ec2:RunInstances",
          "ec2:CreateFleet"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = var.aws_region
          }
        }
      }
    ]
  })
}

resource "helm_release" "this" {
  namespace        = "kube-system"
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = var.karpenter_version
  wait             = true
  create_namespace = false

  values = [
    yamlencode({
      replicas = var.karpenter_replicas
      settings = {
        clusterName       = var.cluster_name
        clusterEndpoint   = var.cluster_endpoint
        interruptionQueue = module.this.queue_name
      }
      tolerations = [
        {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }
      ]
    })
  ]

  depends_on = [module.this]
}

resource "kubectl_manifest" "node_class" {
  yaml_body = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "default"
    }
    spec = {
      role = module.this.node_iam_role_name
      amiSelectorTerms = [
        { alias = "al2023@latest" }
      ]
      subnetSelectorTerms = [
        { tags = { "karpenter.sh/discovery" = var.cluster_name } }
      ]
      securityGroupSelectorTerms = [
        { tags = { "karpenter.sh/discovery" = var.cluster_name } }
      ]
      tags = merge(var.tags, {
        "karpenter.sh/discovery" = var.cluster_name
        "country"                = var.country
        "owner"                  = var.owner
        "name"                   = "${var.cluster_name}-karpenter"
      })
    }
  })

  depends_on = [helm_release.this]
}

resource "kubectl_manifest" "node_pool" {
  yaml_body = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "default"
    }
    spec = {
      template = {
        metadata = {
          labels = {
            role = "workload"
          }
        }
        spec = {
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "default"
          }
          requirements = [
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = var.capacity_types
            },
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["amd64"]
            },
            {
              key      = "node.kubernetes.io/instance-type"
              operator = "In"
              values   = var.instance_types
            }
          ]
        }
      }
      limits = {
        cpu    = var.cpu_limit
        memory = var.memory_limit
      }
      disruption = {
        consolidationPolicy = "WhenEmptyOrUnderutilized"
        consolidateAfter    = "1m"
      }
    }
  })

  depends_on = [kubectl_manifest.node_class]
}
