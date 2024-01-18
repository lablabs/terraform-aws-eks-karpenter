variable "enable_0_29_x_support" {
  type        = bool
  default     = false
  description = "Whether to enable 0.29.x support"
}

data "aws_iam_policy_document" "this_0_29_x" {
  count = local.irsa_role_create && var.irsa_policy_enabled && !var.irsa_assume_role_enabled && var.enable_0_29_x_support ? 1 : 0

  #checkov:skip=CKV_AWS_111:In the future, we may further lock down ec2:RunInstances by using tags in related resources.
  #checkov:skip=CKV_AWS_356: Describe need to be allowed on all resources
  statement {
    sid = "NodeResourceCreation"
    actions = [
      "ec2:CreateLaunchTemplate",
      "ec2:CreateFleet",
      "ec2:CreateTags",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeSpotPriceHistory",
      "pricing:GetProducts",
      "ec2:RunInstances"
    ]
    resources = ["*"]
  }

  statement {
    sid = "NodeResourceDeletion"
    actions = [
      "ec2:TerminateInstances",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }
  }

  statement {
    sid = "KarpenterResourceDeletion"
    actions = [
      "ec2:DeleteLaunchTemplate",
    ]

    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/karpenter.k8s.aws/cluster"
      values   = [var.cluster_name]
    }
  }

  statement {
    sid       = "GetParameters"
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:ssm:*:*:parameter/aws/service/*"]
  }

  statement {
    sid = "PassRole"
    actions = [
      "iam:PassRole"
    ]
    resources = var.karpenter_node_role_arns
    effect    = "Allow"
  }

  statement {
    sid = "EKSClusterEndpointLookup"
    actions = [
      "eks:DescribeCluster"
    ]
    resources = ["arn:${var.aws_partition}:eks:${data.aws_region.this[0].name}:${data.aws_caller_identity.this[0].id}:cluster/${var.cluster_name}"]
    effect    = "Allow"
  }

  statement {
    sid = "HandleInterruptionsQueueMessages"
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
    ]
    resources = [aws_sqs_queue.this[0].arn]
  }
}

resource "aws_iam_policy" "this_0_29_x" {
  count = local.irsa_role_create && (var.irsa_policy_enabled || var.irsa_assume_role_enabled) && var.enable_0_29_x_support ? 1 : 0

  name        = "${var.irsa_role_name_prefix}-${var.helm_chart_name}-0-29-x"
  path        = "/"
  description = "Policy for Karpenter 0.29.x service"
  policy      = var.irsa_assume_role_enabled ? data.aws_iam_policy_document.this_assume[0].json : data.aws_iam_policy_document.this_0_29_x[0].json

  tags = var.irsa_tags
}

resource "aws_iam_role_policy_attachment" "this_0_29_x" {
  count      = local.irsa_role_create && var.irsa_policy_enabled && var.enable_0_29_x_support ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this_0_29_x[0].arn
}
