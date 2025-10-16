/**
 * # AWS EKS Karpenter Terraform module
 *
 * A Terraform module to deploy the [Karpenter](https://karpenter.sh/) on Amazon EKS cluster.
 *
 * [![Terraform validate](https://github.com/lablabs/terraform-aws-eks-karpenter/actions/workflows/validate.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-karpenter/actions/workflows/validate.yaml)
 * [![pre-commit](https://github.com/lablabs/terraform-aws-eks-karpenter/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-karpenter/actions/workflows/pre-commit.yaml)
 */
locals {
  helm_repo_url = var.argo_enabled == true ? "public.ecr.aws/karpenter" : "oci://public.ecr.aws/karpenter"

  crds = {
    name = "karpenter-crds"

    helm_chart_name       = "karpenter-crd"
    helm_chart_version    = "1.8.1"
    helm_repo_url         = local.helm_repo_url
    helm_create_namespace = false # CRDs are cluster-wide resources

    argo_kubernetes_manifest_wait_fields = {
      "status.sync.status"   = "Synced"
      "status.health.status" = "Healthy"
    }
  }

  crds_values = yamlencode({})

  addon = {
    name = "karpenter"

    helm_chart_version = "1.8.1"
    helm_repo_url      = local.helm_repo_url
    helm_skip_crds     = var.crds_enabled # CRDs are installed by the CRDs module, if enabled
  }

  addon_irsa = {
    (local.addon.name) = {
      irsa_policy_enabled = local.irsa_policy_enabled
      irsa_policy         = var.irsa_policy != null ? var.irsa_policy : try(data.aws_iam_policy_document.this[0].json, "")
    }
  }

  addon_values = yamlencode({
    settings = {
      clusterEndpoint   = one(data.aws_eks_cluster.this[*].endpoint)
      clusterName       = var.cluster_name
      interruptionQueue = one(aws_sqs_queue.this[*].name)
    }

    serviceAccount = {
      create = module.addon-irsa[local.addon.name].service_account_create
      name   = module.addon-irsa[local.addon.name].service_account_name
      annotations = module.addon-irsa[local.addon.name].irsa_role_enabled ? {
        "eks.amazonaws.com/role-arn" = module.addon-irsa[local.addon.name].iam_role_attributes.arn
      } : tomap({})
    }
  })

  addon_depends_on = [
    module.crds
  ]
}

data "aws_eks_cluster" "this" {
  count = var.enabled ? 1 : 0
  name  = var.cluster_name
}

data "aws_partition" "current" {
  count = var.enabled ? 1 : 0
}
