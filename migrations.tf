moved {
  from = helm_release.crds_argo_application
  to   = module.crds.helm_release.argo_application
}

moved {
  from = kubernetes_manifest.crds
  to   = module.crds.kubernetes_manifest.this
}

moved {
  from = helm_release.crds
  to   = module.crds.helm_release.this
}

moved {
  from = kubernetes_job.crds_helm_argo_application_wait
  to   = module.crds.kubernetes_job.helm_argo_application_wait
}

moved {
  from = kubernetes_role.crds_helm_argo_application_wait
  to   = module.crds.kubernetes_role.helm_argo_application_wait
}

moved {
  from = kubernetes_role_binding.crds_helm_argo_application_wait
  to   = module.crds.kubernetes_role_binding.helm_argo_application_wait
}

moved {
  from = kubernetes_service_account.crds_helm_argo_application_wait
  to   = module.crds.kubernetes_service_account.helm_argo_application_wait
}

moved {
  from = kubernetes_manifest.this
  to   = module.addon.kubernetes_manifest.this
}

moved {
  from = helm_release.controller
  to   = module.addon.helm_release.this
}

moved {
  from = helm_release.argo_application
  to   = module.addon.helm_release.argo_application
}

moved {
  from = kubernetes_job.helm_argo_application_wait
  to   = module.addon.kubernetes_job.helm_argo_application_wait
}

moved {
  from = kubernetes_role.helm_argo_application_wait
  to   = module.addon.kubernetes_role.helm_argo_application_wait
}

moved {
  from = kubernetes_role_binding.helm_argo_application_wait
  to   = module.addon.kubernetes_role_binding.helm_argo_application_wait
}

moved {
  from = kubernetes_service_account.helm_argo_application_wait
  to   = module.addon.kubernetes_service_account.helm_argo_application_wait
}

moved {
  from = aws_iam_role.this
  to   = module.addon-irsa["karpenter"].aws_iam_role.this
}

moved {
  from = aws_iam_policy.this
  to   = module.addon-irsa["karpenter"].aws_iam_policy.this
}

moved {
  from = aws_iam_role_policy_attachment.this
  to   = module.addon-irsa["karpenter"].aws_iam_role_policy_attachment.this
}
