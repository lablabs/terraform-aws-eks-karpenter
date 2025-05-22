locals {
  helm_chart_name          = var.helm_chart_name != null ? var.helm_chart_name : local.addon.name
  aws_partition_dns_suffix = data.aws_partition.current[0].dns_suffix
}

data "aws_partition" "current" {
  count = var.enabled ? 1 : 0
}

resource "aws_sqs_queue" "this" {
  count = var.enabled ? 1 : 0
  #checkov:skip=CKV_AWS_27:Nothing sensitive
  name                      = "${var.queue_interruption_prefix}-${local.helm_chart_name}"
  message_retention_seconds = 300
  tags                      = var.irsa_tags
}

data "aws_iam_policy_document" "queue" {
  count = var.enabled ? 1 : 0

  statement {
    sid       = "SqsWrite"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.this[0].arn]

    principals {
      type = "Service"
      identifiers = [
        "events.${local.aws_partition_dns_suffix}",
        "sqs.${local.aws_partition_dns_suffix}",
      ]
    }

  }
}

resource "aws_sqs_queue_policy" "this" {
  count = var.enabled ? 1 : 0

  queue_url = aws_sqs_queue.this[0].url
  policy    = data.aws_iam_policy_document.queue[0].json
}

# Node Termination Event Rules
locals {
  events = {
    health_event = {
      name        = "HealthEvent"
      description = "Karpenter interrupt - AWS health event"
      event_pattern = {
        source      = ["aws.health"]
        detail-type = ["AWS Health Event"]
      }
    }
    spot_interupt = {
      name        = "SpotInterrupt"
      description = "Karpenter interrupt - EC2 spot instance interruption warning"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Spot Instance Interruption Warning"]
      }
    }
    instance_rebalance = {
      name        = "InstanceRebalance"
      description = "Karpenter interrupt - EC2 instance rebalance recommendation"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance Rebalance Recommendation"]
      }
    }
    instance_state_change = {
      name        = "InstanceStateChange"
      description = "Karpenter interrupt - EC2 instance state-change notification"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance State-change Notification"]
      }
    }
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each = { for k, v in local.events : k => v if var.enabled }

  name_prefix   = "${var.rule_interruption_prefix}${each.value.name}-"
  description   = each.value.description
  event_pattern = jsonencode(each.value.event_pattern)

  tags = var.irsa_tags
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = { for k, v in local.events : k => v if var.enabled }

  rule      = aws_cloudwatch_event_rule.this[each.key].name
  target_id = "KarpenterInterruptionQueueTarget"
  arn       = aws_sqs_queue.this[0].arn
}
