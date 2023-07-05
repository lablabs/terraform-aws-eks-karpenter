locals {
  irsa_role_create = var.enabled && var.rbac_create && var.service_account_create && var.irsa_role_create
}

data "aws_region" "this" {}

data "aws_caller_identity" "this" {}

data "aws_iam_policy_document" "this" {
  count = local.irsa_role_create && var.irsa_policy_enabled && !var.irsa_assume_role_enabled ? 1 : 0

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
    resources = ["arn:${var.aws_partition}:eks:${data.aws_region.this.name}:${data.aws_caller_identity.this.id}:cluster/${var.cluster_name}"]
    effect    = "Allow"
  }

  dynamic "statement" {
    for_each = var.enabled ? [0] : []

    content {
      sid = "HandleInteruptionsQueueMessages"
      actions = [
        "sqs:DeleteMessage",
        "sqs:GetQueueUrl",
        "sqs:GetQueueAttributes",
        "sqs:ReceiveMessage",
      ]
      resources = [aws_sqs_queue.this[0].arn]
    }
  }
}

data "aws_iam_policy_document" "this_assume" {
  count = local.irsa_role_create && var.irsa_assume_role_enabled ? 1 : 0

  statement {
    sid    = "AllowAssumeKarpenterRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      var.irsa_assume_role_arn
    ]
  }
}

resource "aws_iam_policy" "this" {
  count = local.irsa_role_create && (var.irsa_policy_enabled || var.irsa_assume_role_enabled) ? 1 : 0

  name        = "${var.irsa_role_name_prefix}-${var.helm_chart_name}"
  path        = "/"
  description = "Policy for Karpenter service"
  policy      = var.irsa_assume_role_enabled ? data.aws_iam_policy_document.this_assume[0].json : data.aws_iam_policy_document.this[0].json

  tags = var.irsa_tags
}

data "aws_iam_policy_document" "this_irsa" {
  count = local.irsa_role_create ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.cluster_identity_oidc_issuer_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_identity_oidc_issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${var.namespace}:${var.service_account_name}",
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "this" {
  count              = local.irsa_role_create ? 1 : 0
  name               = "${var.irsa_role_name_prefix}-${var.helm_chart_name}"
  assume_role_policy = data.aws_iam_policy_document.this_irsa[0].json
  tags               = var.irsa_tags
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = local.irsa_role_create && var.irsa_policy_enabled ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_iam_role_policy_attachment" "this_additional" {
  for_each = local.irsa_role_create ? var.irsa_additional_policies : {}

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}
