locals {
  irsa_role_create = var.enabled && var.rbac_create && var.service_account_create && var.irsa_role_create
}

data "aws_iam_policy_document" "this" {
  count = local.irsa_role_create && var.irsa_policy_enabled && !var.irsa_assume_role_enabled ? 1 : 0

  statement {
    sid = "NodeResourceCreation"
    actions = [
      # Write Operations
      "ec2:CreateLaunchTemplate",
      "ec2:CreateFleet",
      "ec2:RunInstances",
      "ec2:CreateTags",
      "ec2:TerminateInstances",
      "ec2:DeleteLaunchTemplate",
      # Read Operations
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeInstances",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeSpotPriceHistory",
      "ssm:GetParameter",
      "pricing:GetProducts"
    ]
    resources = [ #checkov:skip=CKV_AWS_111
      "*"         #checkov:skip=CKV_AWS_108
    ]
    effect = "Allow"
  }
  statement {
    sid = "PassRole"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      var.karpenter_node_role_arn
    ]
    effect = "Allow"
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
