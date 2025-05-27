locals {
  irsa_policy_enabled = var.irsa_policy_enabled != null ? var.irsa_policy_enabled : coalesce(var.irsa_assume_role_enabled, false) == false
}

data "aws_region" "this" {
  count = var.enabled ? 1 : 0
}

data "aws_caller_identity" "this" {
  count = var.enabled ? 1 : 0
}

data "aws_iam_policy_document" "this" {
  #checkov:skip=CKV_AWS_111: In the future, we may further lock down ec2:RunInstances by using tags in related resources.
  #checkov:skip=CKV_AWS_356: Describe need to be allowed on all resources
  count = var.enabled && var.irsa_policy == null && local.irsa_policy_enabled ? 1 : 0

  # Aligned with https://github.com/aws/karpenter-provider-aws/blob/main/website/content/en/v1.4/getting-started/getting-started-with-karpenter/cloudformation.yaml
  statement {
    sid    = "AllowScopedEC2InstanceAccessActions"
    effect = "Allow"

    resources = [
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}::image/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}::snapshot/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:security-group/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:subnet/*",
    ]

    actions = [
      "ec2:RunInstances",
      "ec2:CreateFleet",
    ]
  }

  statement {
    sid       = "AllowScopedEC2LaunchTemplateAccessActions"
    effect    = "Allow"
    resources = ["arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:launch-template/*"]

    actions = [
      "ec2:RunInstances",
      "ec2:CreateFleet",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  statement {
    sid    = "AllowScopedEC2InstanceActionsWithTags"
    effect = "Allow"

    resources = [
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:fleet/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:instance/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:volume/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:network-interface/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:launch-template/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:spot-instances-request/*",
    ]

    actions = [
      "ec2:RunInstances",
      "ec2:CreateFleet",
      "ec2:CreateLaunchTemplate",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = [
        var.cluster_name
      ]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  statement {
    sid    = "AllowScopedResourceCreationTagging"
    effect = "Allow"

    resources = [
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:fleet/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:instance/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:volume/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:network-interface/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:launch-template/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:spot-instances-request/*",
    ]

    actions = ["ec2:CreateTags"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition { # Karpenter v1 Migration: Include additional tag-scoping for the eks:eks-cluster-name tag - https://karpenter.sh/docs/reference/cloudformation/#allowscopedresourcetagging
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"

      values = [
        var.cluster_name
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"

      values = [
        "RunInstances",
        "CreateFleet",
        "CreateLaunchTemplate",
      ]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  statement {
    sid       = "AllowScopedResourceTagging"
    effect    = "Allow"
    resources = ["arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:instance/*"]
    actions   = ["ec2:CreateTags"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }

    condition { # Karpenter v1 Migration: Include additional tag-scoping for the eks:eks-cluster-name tag - https://karpenter.sh/docs/reference/cloudformation/#allowscopedresourcetagging
      test     = "StringEqualsIfExists"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values = [
        var.cluster_name
      ]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"

      values = [
        "eks:eks-cluster-name",
        "karpenter.sh/nodeclaim",
        "Name",
      ]
    }
  }

  statement {
    sid    = "AllowScopedDeletion"
    effect = "Allow"

    resources = [
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:instance/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:launch-template/*",
    ]

    actions = [
      "ec2:TerminateInstances",
      "ec2:DeleteLaunchTemplate",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  statement {
    sid       = "AllowRegionalReadActions"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:DescribeAvailabilityZones", # Missing in the example but its there in description: https://karpenter.sh/docs/reference/cloudformation/#allowregionalreadactions
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [data.aws_region.this[0].name]
    }
  }

  statement {
    sid       = "AllowSSMReadActions"
    effect    = "Allow"
    resources = ["arn:${var.aws_partition}:ssm:${data.aws_region.this[0].name}::parameter/aws/service/*"]
    actions   = ["ssm:GetParameter"]
  }

  statement {
    sid       = "AllowPricingReadActions"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["pricing:GetProducts"]
  }

  statement {
    sid       = "AllowInterruptionQueueActions"
    effect    = "Allow"
    resources = [aws_sqs_queue.this[0].arn]

    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
    ]
  }

  statement {
    sid       = "AllowPassingInstanceRole"
    effect    = "Allow"
    resources = var.karpenter_node_role_arns
    actions   = ["iam:PassRole"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com", "ec2.amazonaws.com.cn"]
    }
  }

  statement {
    sid       = "AllowScopedInstanceProfileCreationActions"
    effect    = "Allow"
    resources = ["arn:${var.aws_partition}:iam::${data.aws_caller_identity.this[0].account_id}:instance-profile/*"]
    actions   = ["iam:CreateInstanceProfile"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = [
        var.cluster_name
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/topology.kubernetes.io/region"
      values   = [data.aws_region.this[0].name]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }
  }

  statement {
    sid       = "AllowScopedInstanceProfileTagActions"
    effect    = "Allow"
    resources = ["arn:${var.aws_partition}:iam::${data.aws_caller_identity.this[0].account_id}:instance-profile/*"]
    actions   = ["iam:TagInstanceProfile"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/topology.kubernetes.io/region"
      values   = [data.aws_region.this[0].name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = [
        var.cluster_name
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/topology.kubernetes.io/region"
      values   = [data.aws_region.this[0].name]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }
  }

  statement {
    sid       = "AllowScopedInstanceProfileActions"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:DeleteInstanceProfile",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/topology.kubernetes.io/region"
      values   = [data.aws_region.this[0].name]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }
  }

  statement {
    sid       = "AllowInstanceProfileReadActions"
    effect    = "Allow"
    resources = ["arn:${var.aws_partition}:iam::${data.aws_caller_identity.this[0].account_id}:instance-profile/*"]
    actions   = ["iam:GetInstanceProfile"]
  }

  statement {
    sid       = "AllowAPIServerEndpointDiscovery"
    effect    = "Allow"
    resources = ["arn:${var.aws_partition}:eks:${data.aws_region.this[0].name}:${data.aws_caller_identity.this[0].account_id}:cluster/${var.cluster_name}"]
    actions   = ["eks:DescribeCluster"]
  }
}
