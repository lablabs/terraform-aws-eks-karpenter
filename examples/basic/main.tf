resource "aws_iam_role" "this" {
  name               = "karpenter-node-role"
  assume_role_policy = data.aws_iam_policy_document.karpenter_node_assume_policy.json
}

data "aws_iam_policy_document" "karpenter_node_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}

module "addon_installation_disabled" {
  source = "../../"

  enabled = false

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
  cluster_name                     = module.eks_cluster.eks_cluster_id
  karpenter_node_role_arns         = aws_iam_role.this.arn
}

module "addon_installation_helm" {
  source = "../../"

  enabled           = true
  argo_enabled      = false
  argo_helm_enabled = false

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
  cluster_name                     = module.eks_cluster.eks_cluster_id
  karpenter_node_role_arns         = aws_iam_role.this.arn

  values = yamlencode({
    # insert sample values here
  })
}

# Please, see README.md and Argo Kubernetes deployment method for implications of using Kubernetes installation method
module "addon_installation_argo_kubernetes" {
  source = "../../"

  enabled           = true
  argo_enabled      = true
  argo_helm_enabled = false

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
  cluster_name                     = module.eks_cluster.eks_cluster_id
  karpenter_node_role_arns         = aws_iam_role.this.arn

  values = yamlencode({
    # insert sample values here
  })

  argo_sync_policy = {
    "automated" : {}
    "syncOptions" = ["CreateNamespace=true"]
  }
}


module "addon_installation_argo_helm" {
  source = "../../"

  enabled           = true
  argo_enabled      = true
  argo_helm_enabled = true

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
  cluster_name                     = module.eks_cluster.eks_cluster_id
  karpenter_node_role_arns         = aws_iam_role.this.arn
  argo_sync_policy = {
    "automated" : {}
    "syncOptions" = ["CreateNamespace=true"]
  }
}
