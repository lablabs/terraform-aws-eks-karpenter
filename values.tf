locals {
  values_default = yamlencode({
    "clusterEndpoint" : data.aws_eks_cluster.this.endpoint
    "clusterName" : var.cluster_name
    "serviceAccount" : {
      "annotations" : {
        "eks.amazonaws.com/role-arn" : local.irsa_role_create ? aws_iam_role.this[0].arn : ""
      }
    }
  })
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "utils_deep_merge_yaml" "values" {
  count = var.enabled ? 1 : 0
  input = compact([
    local.values_default,
    var.values
  ])
}
