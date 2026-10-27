resource "aws_efs_file_system" "this" {
  creation_token = "${var.cluster_name}-efs"
  encrypted      = true
  throughput_mode = var.throughput_mode

  lifecycle_policy {
    transition_to_ia = var.transition_to_ia
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-efs"
  })
}

resource "aws_security_group" "efs" {
  name_prefix = "${var.cluster_name}-efs-"
  description = "Allow NFS traffic from VPC CIDR"
  vpc_id      = var.vpc_id

  ingress {
    description = "NFS from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-efs"
  })
}

resource "aws_efs_mount_target" "this" {
  count = length(var.subnet_ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}

module "efs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${var.cluster_name}-efs-csi"

  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

resource "aws_eks_addon" "efs_csi" {
  cluster_name             = var.cluster_name
  addon_name               = "aws-efs-csi-driver"
  addon_version            = data.aws_eks_addon_version.efs_csi.version
  service_account_role_arn = module.efs_csi_irsa.iam_role_arn
  resolve_conflicts_on_create = "OVERWRITE"

  tags = var.tags

  depends_on = [aws_efs_mount_target.this]
}

data "aws_eks_addon_version" "efs_csi" {
  addon_name         = "aws-efs-csi-driver"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

resource "kubernetes_storage_class" "efs" {
  metadata {
    name = "efs"
  }

  storage_provisioner = "efs.csi.aws.com"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.this.id
    directoryPerms   = "700"
  }

  reclaim_policy      = "Delete"
  volume_binding_mode = "Immediate"

  depends_on = [aws_eks_addon.efs_csi]
}
