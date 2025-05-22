/**
 * # AWS EKS Universal Addon Terraform module
 *
 * A Terraform module to deploy the universal addon on Amazon EKS cluster.
 *
 * [![Terraform validate](https://github.com/lablabs/terraform-aws-eks-universal-addon/actions/workflows/validate.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-universal-addon/actions/workflows/validate.yaml)
 * [![pre-commit](https://github.com/lablabs/terraform-aws-eks-universal-addon/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-universal-addon/actions/workflows/pre-commit.yaml)
 */
locals {
  crds = {
    name = "karpenter-crds"

    helm_chart_name       = "karpenter-crd"
    helm_chart_version    = "1.4.0"
    helm_repo_url         = "public.ecr.aws"
    helm_create_namespace = false # CRDs are cluster-wide resources

    argo_sync_policy = {
      automated = {}
      syncOptions = [
        "ServerSideApply=true"
      ]
    }

    argo_kubernetes_manifest_wait_fields = {
      "status.sync.status"   = "Synced"
      "status.health.status" = "Healthy"
    }
  }

  crds_values = yamlencode({})

  addon = {
    name = "karpenter"

    helm_chart_version = "1.4.0"
    helm_repo_url      = "public.ecr.aws"
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
