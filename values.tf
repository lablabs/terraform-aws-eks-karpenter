locals {
  values_default = yamlencode({
    settings = {
      aws = {
        clusterEndpoint       = one(data.aws_eks_cluster.this[*].endpoint)
        clusterName           = var.cluster_name
        interruptionQueueName = one(aws_sqs_queue.this[*].name)
      }
    }
    serviceAccount = {
      create = var.service_account_create
      name   = var.service_account_name
      annotations = {
        "eks.amazonaws.com/role-arn" : local.irsa_role_create ? aws_iam_role.this[0].arn : ""
      }
    }
  })

  crds_values_default = yamlencode({
    # add default values here
  })
}

data "aws_eks_cluster" "this" {
  count = var.enabled ? 1 : 0
  name  = var.cluster_name
}

data "utils_deep_merge_yaml" "crds_values" {
  count = var.enabled ? 1 : 0
  input = compact([
    local.crds_values_default,
    var.crds_values
  ])
}

data "utils_deep_merge_yaml" "values" {
  count = var.enabled ? 1 : 0
  input = compact([
    local.values_default,
    var.values
  ])
}
