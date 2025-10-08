variable "aws_partition" {
  type        = string
  default     = "aws"
  description = "DEPRECATED: Use of `data.aws_partition` is preferred. AWS partition in which the resources are located. Avaliable values are `aws`, `aws-cn`, `aws-us-gov`"
}
