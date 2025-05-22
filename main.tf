/**
 * # AWS EKS Universal Addon Terraform module
 *
 * A Terraform module to deploy the universal addon on Amazon EKS cluster.
 *
 * [![Terraform validate](https://github.com/lablabs/terraform-aws-eks-universal-addon/actions/workflows/validate.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-universal-addon/actions/workflows/validate.yaml)
 * [![pre-commit](https://github.com/lablabs/terraform-aws-eks-universal-addon/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-universal-addon/actions/workflows/pre-commit.yaml)
 */

locals {
  addon = {
    name = "universal-addon"

    helm_chart_name    = "raw"
    helm_chart_version = "0.1.0"
    helm_repo_url      = "https://lablabs.github.io"
  }

  addon_irsa = {
    (local.addon.name) = {
    }
  }

  addon_values = yamlencode({
  })

  addon_depends_on = [
  ]
}
