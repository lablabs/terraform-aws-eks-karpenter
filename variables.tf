# IMPORTANT: Add addon specific variables here
variable "karpenter_node_role_arns" {
  type        = list(any)
  default     = ["*"]
  description = "List of roles arns which can be passed from karpenter service to newly created nodes"
}

variable "aws_partition" {
  type        = string
  default     = "aws"
  description = "AWS partition in which the resources are located. Avaliable values are `aws`, `aws-cn`, `aws-us-gov`"
}

variable "queue_interruption_prefix" {
  type        = string
  default     = "interruption-queue"
  description = "Custom prefix for karpenter spot interruption queue"
}

variable "rule_interruption_prefix" {
  type        = string
  default     = "Karpenter"
  description = "Prefix used for all event bridge rules"
}
