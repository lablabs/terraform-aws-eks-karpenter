# ================ crd common variables (required) ================

variable "crds_helm_chart_name" {
  type        = string
  default     = "karpenter-crd"
  description = "Helm chart name to be installed"
}

variable "crds_helm_chart_version" {
  type        = string
  default     = "0.36.1"
  description = "Version of the Helm chart"
}

variable "crds_helm_release_name" {
  type        = string
  default     = "karpenter-crds"
  description = "Helm release name"
}

variable "crds_settings" {
  type        = map(any)
  default     = {}
  description = "Additional helm sets which will be passed to the Helm chart values, see https://github.com/aws/karpenter/tree/main/charts/karpenter-crd"
}

variable "crds_values" {
  type        = string
  default     = ""
  description = "Additional yaml encoded values which will be passed to the Helm chart, see https://github.com/aws/karpenter/tree/main/charts/karpenter-crd"
}

# ================ argo variables (required) ================

variable "crds_argo_sync_policy" {
  type        = any
  description = "ArgoCD syncPolicy manifest parameter"
  default     = {}
}

variable "crds_argo_metadata" {
  type = any
  default = {
    "finalizers" : [
      "resources-finalizer.argocd.argoproj.io"
    ]
  }
  description = "ArgoCD Application metadata configuration. Override or create additional metadata parameters"
}

variable "crds_argo_spec" {
  type        = any
  default     = {}
  description = "ArgoCD Application spec configuration. Override or create additional spec parameters"
}

variable "crds_argo_helm_values" {
  type        = string
  default     = ""
  description = "Value overrides to use when deploying argo application object with helm"
}

# ================ argo kubernetes manifest variables (required) ================

variable "crds_argo_kubernetes_manifest_computed_fields" {
  type        = list(string)
  default     = ["metadata.labels", "metadata.annotations", "metadata.finalizers"]
  description = "List of paths of fields to be handled as \"computed\". The user-configured value for the field will be overridden by any different value returned by the API after apply."
}

variable "crds_argo_kubernetes_manifest_field_manager_name" {
  type        = string
  default     = "Terraform"
  description = "The name of the field manager to use when applying the kubernetes manifest resource. Defaults to Terraform"
}

variable "crds_argo_kubernetes_manifest_field_manager_force_conflicts" {
  type        = bool
  default     = false
  description = "Forcibly override any field manager conflicts when applying the kubernetes manifest resource"
}

variable "crds_argo_kubernetes_manifest_wait_fields" {
  type        = map(string)
  default     = {}
  description = "A map of fields and a corresponding regular expression with a pattern to wait for. The provider will wait until the field matches the regular expression. Use * for any value."
}

# ================ helm release variables (required) ================

variable "crds_helm_devel" {
  type        = bool
  default     = false
  description = "Use helm chart development versions, too. Equivalent to version '>0.0.0-0'. If version is set, this is ignored"
}

variable "crds_helm_package_verify" {
  type        = bool
  default     = false
  description = "Verify the package before installing it. Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart"
}

variable "crds_helm_keyring" {
  type        = string
  default     = "~/.gnupg/pubring.gpg"
  description = "Location of public keys used for verification. Used only if helm_package_verify is true"
}

variable "crds_helm_timeout" {
  type        = number
  default     = 300
  description = "Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks)"
}

variable "crds_helm_disable_webhooks" {
  type        = bool
  default     = false
  description = "Prevent helm chart hooks from running"
}

variable "crds_helm_reset_values" {
  type        = bool
  default     = false
  description = "When upgrading, reset the values to the ones built into the helm chart"
}

variable "crds_helm_reuse_values" {
  type        = bool
  default     = false
  description = "When upgrading, reuse the last helm release's values and merge in any overrides. If 'helm_reset_values' is specified, this is ignored"
}

variable "crds_helm_force_update" {
  type        = bool
  default     = false
  description = "Force helm resource update through delete/recreate if needed"
}

variable "crds_helm_recreate_pods" {
  type        = bool
  default     = false
  description = "Perform pods restart during helm upgrade/rollback"
}

variable "crds_helm_cleanup_on_fail" {
  type        = bool
  default     = false
  description = "Allow deletion of new resources created in this helm upgrade when upgrade fails"
}

variable "crds_helm_release_max_history" {
  type        = number
  default     = 0
  description = "Maximum number of release versions stored per release"
}

variable "crds_helm_atomic" {
  type        = bool
  default     = false
  description = "If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used"
}

variable "crds_helm_wait" {
  type        = bool
  default     = true
  description = "Will wait until all helm release resources are in a ready state before marking the release as successful. It will wait for as long as timeout"
}

variable "crds_helm_wait_for_jobs" {
  type        = bool
  default     = false
  description = "If wait is enabled, will wait until all helm Jobs have been completed before marking the release as successful. It will wait for as long as timeout"
}

variable "crds_helm_render_subchart_notes" {
  type        = bool
  default     = true
  description = "If set, render helm subchart notes along with the parent"
}

variable "crds_helm_disable_openapi_validation" {
  type        = bool
  default     = false
  description = "If set, the installation process will not validate rendered helm templates against the Kubernetes OpenAPI Schema"
}

variable "crds_helm_dependency_update" {
  type        = bool
  default     = false
  description = "Runs helm dependency update before installing the chart"
}

variable "crds_helm_replace" {
  type        = bool
  default     = false
  description = "Re-use the given name of helm release, only if that name is a deleted release which remains in the history. This is unsafe in production"
}

variable "crds_helm_description" {
  type        = string
  default     = ""
  description = "Set helm release description attribute (visible in the history)"
}

variable "crds_helm_lint" {
  type        = bool
  default     = false
  description = "Run the helm chart linter during the plan"
}

variable "crds_helm_set_sensitive" {
  type        = map(any)
  default     = {}
  description = "Value block with custom sensitive values to be merged with the values yaml that won't be exposed in the plan's diff"
}

variable "crds_helm_postrender" {
  type        = map(any)
  default     = {}
  description = "Value block with a path to a binary file to run after helm renders the manifest which can alter the manifest contents"
}
