module "this" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  authentication_mode = "API"
  enable_irsa         = true

  cluster_addons = {
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
      })
    }
    coredns = {
      most_recent = true
      configuration_values = jsonencode({
        tolerations = [
          {
            key      = "CriticalAddonsOnly"
            operator = "Exists"
          }
        ]
      })
    }
    kube-proxy = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    bootstrap = {
      name                     = "${var.cluster_name}-bootstrap"
      iam_role_use_name_prefix = false
      ami_type                 = "AL2023_x86_64_STANDARD"
      instance_types           = [var.bootstrap_instance_type]
      min_size                 = var.bootstrap_min_size
      max_size                 = var.bootstrap_max_size
      desired_size             = var.bootstrap_desired_size
      capacity_type            = "ON_DEMAND"

      labels = {
        role = "bootstrap"
      }

      taints = {
        critical_only = {
          key    = "CriticalAddonsOnly"
          effect = "NO_SCHEDULE"
        }
      }

      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:${var.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }

      tags = {
        country = var.country
        owner   = var.owner
        name    = "${var.cluster_name}-bootstrap"
      }
    }
  }

  node_security_group_tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }

  enable_cluster_creator_admin_permissions = true

  tags = var.tags
}
