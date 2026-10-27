# SPICE Release Engine

Reusable Terraform modules for deploying applications on AWS EKS.

## Modules

| Module | Description |
|--------|-------------|
| **vpc** | VPC with public/private subnets and NAT gateway |
| **eks-cluster** | EKS cluster with managed bootstrap node group |
| **eks-addons** | EKS managed addons (CoreDNS, kube-proxy, VPC-CNI) |
| **efs** | EFS filesystem with CSI driver and StorageClass |
| **rds-postgres** | Standard RDS PostgreSQL with gp3, encryption, Performance Insights |
| **app-iam** | Application IAM roles with IRSA |
| **karpenter** | Karpenter node autoscaler |
| **ingress** | AWS Load Balancer Controller |
| **argocd** | ArgoCD GitOps platform |
| **monitoring** | Prometheus, Grafana, and Loki |

## Usage

```hcl
module "vpc" {
  source = "git::https://github.com/Medtronic-LABS/spice-release-engine.git//modules/vpc?ref=v1.0.0"

  # module inputs
}
```

Pin to a tag (`?ref=v1.3.0`) for reproducible deployments.

## Versioning

Follows semantic versioning. Tag a release:

```bash
git tag -a v1.1.0 -m "v1.1.0: description"
git push origin v1.1.0
```

## Security

- **Pre-commit hooks** — gitleaks, private key detection, terraform validation
- **GitHub Actions CI** — secret scanning, file type guardrails on every PR
- **`.gitignore`** — blocks state files, credentials, tfvars, and keys

Setup:

```bash
pip install pre-commit
pre-commit install
```

## Releases

| Tag | Changes |
|-----|---------|
| **v1.0.0** | Initial release — all base modules |
| **v1.1.0** | EKS cluster/node security group outputs |
| **v1.2.0** | RDS PostgreSQL module |
| **v1.3.0** | Karpenter configurable consolidation policy and timing |

## Contributing

1. Branch from `main`
2. Install pre-commit hooks
3. Open a PR — CI validates automatically
4. Tag a release after merge if module interfaces changed
