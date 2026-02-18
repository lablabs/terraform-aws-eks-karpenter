locals {
  irsa_policy_enabled = (
    var.enabled                                                                                                             // The addon must be enabled
    && (var.irsa_policy_enabled != null ? var.irsa_policy_enabled : coalesce(var.irsa_assume_role_enabled, false) == false) // IRSA policy is only enabled by default if IRSA is enabled but assume role is not enabled, otherwise we assume the user will provide the necessary permissions in the custom policy
    && var.irsa_policy == null                                                                                              // No custom policy provided
    && module.addon-irsa[local.addon.name].irsa_role_enabled                                                                // IRSA role must be enabled for the policy to be relevant
  )
}

# IAM policies are aligned with https://github.com/aws/karpenter-provider-aws/blob/main/website/content/en/v1.8/getting-started/getting-started-with-karpenter/cloudformation.yaml.
#  Policies are split into multiple policies based on https://karpenter.sh/docs/reference/cloudformation/#controller-authorization due to managed policy length limit of 6,144 characters.
data "aws_iam_policy_document" "node_lifecycle" {
  #checkov:skip=CKV_AWS_111: In the future, we may further lock down ec2:RunInstances by using tags in related resources.
  count = var.enabled && var.irsa_policy == null && local.irsa_policy_enabled ? 1 : 0

  statement {
    sid    = "AllowScopedEC2InstanceAccessActions"
    effect = "Allow"

    resources = [
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}::image/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}::snapshot/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:security-group/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:subnet/*",
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:capacity-reservation/*",
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
      "arn:${var.aws_partition}:ec2:${data.aws_region.this[0].name}:*:capacity-reservation/*",
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
      values = [
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

    # Karpenter v1 Migration: Include additional tag-scoping for the eks:eks-cluster-name tag - https://karpenter.sh/docs/reference/cloudformation/#allowscopedresourcetagging
    condition {
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
}

data "aws_iam_policy_document" "iam_integration" {
  count = local.irsa_policy_enabled ? 1 : 0

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
      values = [
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
      values = [
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
}

data "aws_iam_policy_document" "eks_integration" {
  count = local.irsa_policy_enabled ? 1 : 0

  statement {
    sid       = "AllowAPIServerEndpointDiscovery"
    effect    = "Allow"
    resources = ["arn:${var.aws_partition}:eks:${data.aws_region.this[0].name}:${data.aws_caller_identity.this[0].account_id}:cluster/${var.cluster_name}"]
    actions   = ["eks:DescribeCluster"]
  }
}

data "aws_iam_policy_document" "interruption" {
  count = local.irsa_policy_enabled ? 1 : 0

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
}

data "aws_iam_policy_document" "resource_discovery" {
  #checkov:skip=CKV_AWS_356: Describe need to be allowed on all resources
  count = local.irsa_policy_enabled ? 1 : 0

  statement {
    sid       = "AllowRegionalReadActions"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:DescribeCapacityReservations",
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

  # Required IAM permission for Karpenter v1.7.0 and later to manage EC2 instance profiles:
  # See: https://karpenter.sh/docs/upgrading/upgrade-guide/#upgrading-to-170
  statement {
    sid       = "AllowUnscopedInstanceProfileListAction"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["iam:ListInstanceProfiles"]
  }

  statement {
    sid       = "AllowInstanceProfileReadActions"
    effect    = "Allow"
    resources = ["arn:${var.aws_partition}:iam::${data.aws_caller_identity.this[0].account_id}:instance-profile/*"]
    actions   = ["iam:GetInstanceProfile"]
  }
}

resource "aws_iam_policy" "node_lifecycle" {
  count = local.irsa_policy_enabled ? 1 : 0

  description = "Node lifecycle policy for ${module.addon-irsa[local.addon.name].irsa_iam_role_attributes.name} addon"
  name        = "${module.addon-irsa[local.addon.name].irsa_iam_role_attributes.name}-node-lifecycle" # tflint-ignore: aws_iam_policy_invalid_name
  path        = "/"
  policy      = data.aws_iam_policy_document.node_lifecycle[0].json

  tags = var.irsa_tags
}

resource "aws_iam_role_policy_attachment" "node_lifecycle" {
  count = local.irsa_policy_enabled ? 1 : 0

  role       = module.addon-irsa[local.addon.name].irsa_iam_role_attributes.name
  policy_arn = aws_iam_policy.node_lifecycle[0].arn
}

resource "aws_iam_policy" "iam_integration" {
  count = local.irsa_policy_enabled ? 1 : 0

  description = "IAM integration policy for ${module.addon-irsa[local.addon.name].irsa_iam_role_attributes.name} addon"
  name        = "${module.addon-irsa[local.addon.name].irsa_iam_role_attributes.name}-iam-integration" # tflint-ignore: aws_iam_policy_invalid_name
  path        = "/"
  policy      = data.aws_iam_policy_document.iam_integration[0].json

  tags = var.irsa_tags
}

resource "aws_iam_role_policy_attachment" "iam_integration" {
  count = local.irsa_policy_enabled ? 1 : 0

  role       = module.addon-irsa[local.addon.name].irsa_iam_role_attributes.name
  policy_arn = aws_iam_policy.iam_integration[0].arn
}

resource "aws_iam_policy" "eks_integration" {
  count = local.irsa_policy_enabled ? 1 : 0

  description = "EKS integration policy for ${module.addon-irsa[local.addon.name].irsa_iam_role_attributes.name} addon"
  name        = "${module.addon-irsa[local.addon.name].irsa_iam_role_attributes.name}-eks-integration" # tflint-ignore: aws_iam_policy_invalid_name
  path        = "/"
  policy      = data.aws_iam_policy_document.eks_integration[0].json

  tags = var.irsa_tags
}

resource "aws_iam_role_policy_attachment" "eks_integration" {
  count = local.irsa_policy_enabled ? 1 : 0

  role       = module.addon-irsa[local.addon.name].irsa_iam_role_attributes.name
  policy_arn = aws_iam_policy.eks_integration[0].arn
}

resource "aws_iam_policy" "interruption" {
  count = local.irsa_policy_enabled ? 1 : 0

  description = "Interruption handling policy for ${module.addon-irsa[local.addon.name].irsa_iam_role_attributes.name} addon"
  name        = "${module.addon-irsa[local.addon.name].irsa_iam_role_attributes.name}-interruption" # tflint-ignore: aws_iam_policy_invalid_name
  path        = "/"
  policy      = data.aws_iam_policy_document.interruption[0].json

  tags = var.irsa_tags
}

resource "aws_iam_role_policy_attachment" "interruption" {
  count = local.irsa_policy_enabled ? 1 : 0

  role       = module.addon-irsa[local.addon.name].irsa_iam_role_attributes.name
  policy_arn = aws_iam_policy.interruption[0].arn
}

resource "aws_iam_policy" "resource_discovery" {
  count = local.irsa_policy_enabled ? 1 : 0

  description = "Resource discovery policy for ${module.addon-irsa[local.addon.name].irsa_iam_role_attributes.name} addon"
  name        = "${module.addon-irsa[local.addon.name].irsa_iam_role_attributes.name}-resource-discovery" # tflint-ignore: aws_iam_policy_invalid_name
  path        = "/"
  policy      = data.aws_iam_policy_document.resource_discovery[0].json

  tags = var.irsa_tags
}

resource "aws_iam_role_policy_attachment" "resource_discovery" {
  count = local.irsa_policy_enabled ? 1 : 0

  role       = module.addon-irsa[local.addon.name].irsa_iam_role_attributes.name
  policy_arn = aws_iam_policy.resource_discovery[0].arn
}
