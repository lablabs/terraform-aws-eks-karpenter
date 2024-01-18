terraform {
  required_version = ">= 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.19.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "> 2.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
    utils = {
      source  = "cloudposse/utils"
      version = ">= 0.17.0"
    }
  }
}
