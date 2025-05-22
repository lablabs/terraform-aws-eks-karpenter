variable "crds_helm_enabled" {
  type        = bool
  default     = null
  description = "Set to false to prevent installation of the module via Helm release. Defaults to `true`."
}

variable "crds_helm_chart_name" {
  type        = string
  default     = null
  description = "Helm chart name to be installed. Required if `argo_source_type` is set to `helm`. Defaults to `null`."
}

variable "crds_helm_chart_version" {
  type        = string
  default     = null
  description = "Version of the Helm chart. Required if `argo_source_type` is set to `helm`. Defaults to `null`."
}

variable "crds_helm_release_name" {
  type        = string
  default     = null
  description = "Helm release name. Required if `argo_source_type` is set to `helm`. Defaults to `null`."
}

variable "crds_helm_repo_url" {
  type        = string
  default     = null
  description = "Helm repository. Required if `argo_source_type` is set to `helm`. Defaults to `null`."
}

variable "crds_helm_create_namespace" {
  type        = bool
  default     = null
  description = "Create the Namespace if it does not yet exist. Defaults to `true`."
}

variable "crds_settings" {
  type        = map(any)
  default     = null
  description = "Additional Helm sets which will be passed to the Helm chart values or Kustomize or directory configuration which will be passed to ArgoCD Application source. Defaults to `{}`."
}

variable "crds_values" {
  type        = string
  default     = null
  description = "Additional YAML encoded values which will be passed to the Helm chart. Defaults to `\"\"`."
}

variable "crds_argo_name" {
  type        = string
  default     = null
  description = "Name of the ArgoCD Application. Required if `argo_source_type` is set to `kustomize` or `directory`.  If `argo_source_type` is set to `helm`, ArgoCD Application name will equal `helm_release_name`. Defaults to `null`."
}

variable "crds_argo_namespace" {
  type        = string
  default     = null
  description = "Namespace to deploy ArgoCD Application to. Defaults to `argo`."
}

variable "crds_argo_enabled" {
  type        = bool
  default     = null
  description = "If set to `true`, the module will be deployed as ArgoCD Application, otherwise it will be deployed as a Helm release. Defaults to `false`."
}

variable "crds_argo_helm_enabled" {
  type        = bool
  default     = null
  description = "If set to `true`, the ArgoCD Application manifest will be deployed using Kubernetes provider as a Helm release. Otherwise it'll be deployed as a Kubernetes manifest. See README for more info. Defaults to `false`."
}

variable "crds_argo_helm_wait_timeout" {
  type        = string
  default     = null
  description = "Timeout for ArgoCD Application Helm release wait job. Defaults to `10m`."
}

variable "crds_argo_helm_wait_node_selector" {
  type        = map(string)
  default     = null
  description = "Node selector for ArgoCD Application Helm release wait job. Defaults to `{}`."
}

variable "crds_argo_helm_wait_tolerations" {
  type        = list(any)
  default     = null
  description = "Tolerations for ArgoCD Application Helm release wait job. Defaults to `[]`."
}

variable "crds_argo_helm_wait_backoff_limit" {
  type        = number
  default     = null
  description = "Backoff limit for ArgoCD Application Helm release wait job. Defaults to `6`."
}

variable "crds_argo_helm_wait_kubectl_version" {
  type        = string
  default     = null
  description = "Version of kubectl to use for ArgoCD Application wait job. Defaults to `1.32.3`."
}

variable "crds_argo_source_type" {
  type        = string
  default     = null
  description = "Source type for ArgoCD Application. Can be either `helm`, `kustomize`, or `directory`. Defaults to `helm`."
}

variable "crds_argo_source_repo_url" {
  type        = string
  default     = null
  description = "ArgoCD Application source repo URL. Required if `argo_source_type` is set to `kustomize` or `directory`. Defaults to `null`."
}

variable "crds_argo_source_target_revision" {
  type        = string
  default     = null
  description = "ArgoCD Application source target revision. Required if `argo_source_type` is set to `kustomize` or `directory`. Defaults to `null`."
}

variable "crds_argo_source_path" {
  type        = string
  default     = null
  description = "ArgoCD Application source path. Required if `argo_source_type` is set to `kustomize` or `directory`. Defaults to `null`."
}

variable "crds_argo_destination_server" {
  type        = string
  default     = null
  description = "Destination server for ArgoCD Application. Defaults to `https://kubernetes.default.svc`."
}

variable "crds_argo_project" {
  type        = string
  default     = null
  description = "ArgoCD Application project. Defaults to `default`."
}

variable "crds_argo_info" {
  type        = list(any)
  default     = null
  description = "ArgoCD Application manifest info parameter. Defaults to `[{\"name\": \"terraform\", \"value\": \"true\"}]`."
}

variable "crds_argo_sync_policy" {
  type        = any
  default     = null
  description = "ArgoCD Application manifest syncPolicy parameter. Defaults to `{}`."
}

variable "crds_argo_metadata" {
  type        = any
  default     = null
  description = "ArgoCD Application metadata configuration. Override or create additional metadata parameters. Defaults to `{\"finalizers\": [\"resources-finalizer.argocd.argoproj.io\"]}`."
}

variable "crds_argo_apiversion" {
  type        = string
  default     = null
  description = "ArgoCD Application apiVersion. Defaults to `argoproj.io/v1alpha1`."
}

variable "crds_argo_spec" {
  type        = any
  default     = null
  description = "ArgoCD Application spec configuration. Configuration is extended by deep merging with the default spec parameters. Defaults to `{}`."
}

variable "crds_argo_spec_override" {
  type        = any
  default     = null
  description = "ArgoCD Application spec configuration. Configuration is overriden by merging natively with the default spec parameters. Defaults to `{}`."
}

variable "crds_argo_operation" {
  type        = any
  default     = null
  description = "ArgoCD Application manifest operation parameter. Defaults to `{}`."
}

variable "crds_argo_helm_values" {
  type        = string
  default     = null
  description = "Value overrides to use when deploying ArgoCD Application object with Helm. Defaults to `\"\"`."
}

variable "crds_argo_kubernetes_manifest_computed_fields" {
  type        = list(string)
  default     = null
  description = "List of paths of fields to be handled as \"computed\". The user-configured value for the field will be overridden by any different value returned by the API after apply. Defaults to `[\"metadata.labels\", \"metadata.annotations\", \"metadata.finalizers\"]`."
}

variable "crds_argo_kubernetes_manifest_field_manager_name" {
  type        = string
  default     = null
  description = "The name of the field manager to use when applying the Kubernetes manifest resource. Defaults to `Terraform`."
}

variable "crds_argo_kubernetes_manifest_field_manager_force_conflicts" {
  type        = bool
  default     = null
  description = "Forcibly override any field manager conflicts when applying the kubernetes manifest resource. Defaults to `false`."
}

variable "crds_argo_kubernetes_manifest_wait_fields" {
  type        = map(string)
  default     = null
  description = "A map of fields and a corresponding regular expression with a pattern to wait for. The provider will wait until the field matches the regular expression. Use * for any value. Defaults to `{}`."
}

variable "crds_helm_repo_key_file" {
  type        = string
  default     = null
  description = "Helm repositories cert key file. Defaults to `\"\"`."
}

variable "crds_helm_repo_cert_file" {
  type        = string
  default     = null
  description = "Helm repositories cert file. Defaults to `\"\"`."
}

variable "crds_helm_repo_ca_file" {
  type        = string
  default     = null
  description = "Helm repositories CA cert file. Defaults to `\"\"`."
}

variable "crds_helm_repo_username" {
  type        = string
  default     = null
  description = "Username for HTTP basic authentication against the Helm repository. Defaults to `\"\"`."
}

variable "crds_helm_repo_password" {
  type        = string
  default     = null
  description = "Password for HTTP basic authentication against the Helm repository. Defaults to `\"\"`."
}

variable "crds_helm_devel" {
  type        = bool
  default     = null
  description = "Use Helm chart development versions, too. Equivalent to version '>0.0.0-0'. If version is set, this is ignored. Defaults to `false`."
}

variable "crds_helm_package_verify" {
  type        = bool
  default     = null
  description = "Verify the package before installing it. Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart. Defaults to `false`."
}

variable "crds_helm_keyring" {
  type        = string
  default     = null
  description = "Location of public keys used for verification. Used only if `helm_package_verify` is `true`. Defaults to `~/.gnupg/pubring.gpg`."
}

variable "crds_helm_timeout" {
  type        = number
  default     = null
  description = "Time in seconds to wait for any individual Kubernetes operation (like Jobs for hooks). Defaults to `300`."
}

variable "crds_helm_disable_webhooks" {
  type        = bool
  default     = null
  description = "Prevent Helm chart hooks from running. Defaults to `false`."
}

variable "crds_helm_reset_values" {
  type        = bool
  default     = null
  description = "When upgrading, reset the values to the ones built into the Helm chart. Defaults to `false`."
}

variable "crds_helm_reuse_values" {
  type        = bool
  default     = null
  description = "When upgrading, reuse the last Helm release's values and merge in any overrides. If `helm_reset_values` is specified, this is ignored. Defaults to `false`."
}

variable "crds_helm_force_update" {
  type        = bool
  default     = null
  description = "Force Helm resource update through delete/recreate if needed. Defaults to `false`."
}

variable "crds_helm_recreate_pods" {
  type        = bool
  default     = null
  description = "Perform pods restart during Helm upgrade/rollback. Defaults to `false`."
}

variable "crds_helm_cleanup_on_fail" {
  type        = bool
  default     = null
  description = "Allow deletion of new resources created in this Helm upgrade when upgrade fails. Defaults to `false`."
}

variable "crds_helm_release_max_history" {
  type        = number
  default     = null
  description = "Maximum number of release versions stored per release. Defaults to `0`."
}

variable "crds_helm_atomic" {
  type        = bool
  default     = null
  description = "If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used. Defaults to `false`."
}

variable "crds_helm_wait" {
  type        = bool
  default     = null
  description = "Will wait until all Helm release resources are in a ready state before marking the release as successful. It will wait for as long as timeout. Defaults to `false`."
}

variable "crds_helm_wait_for_jobs" {
  type        = bool
  default     = null
  description = "If wait is enabled, will wait until all Helm Jobs have been completed before marking the release as successful. It will wait for as long as timeout. Defaults to `false`."
}

variable "crds_helm_skip_crds" {
  type        = bool
  default     = null
  description = "If set, no CRDs will be installed before Helm release. Defaults to `false`."
}

variable "crds_helm_render_subchart_notes" {
  type        = bool
  default     = null
  description = "If set, render Helm subchart notes along with the parent. Defaults to `true`."
}

variable "crds_helm_disable_openapi_validation" {
  type        = bool
  default     = null
  description = "If set, the installation process will not validate rendered Helm templates against the Kubernetes OpenAPI Schema. Defaults to `false`."
}

variable "crds_helm_dependency_update" {
  type        = bool
  default     = null
  description = "Runs Helm dependency update before installing the chart. Defaults to `false`."
}

variable "crds_helm_replace" {
  type        = bool
  default     = null
  description = "Re-use the given name of Helm release, only if that name is a deleted release which remains in the history. This is unsafe in production. Defaults to `false`."
}

variable "crds_helm_description" {
  type        = string
  default     = null
  description = "Set Helm release description attribute (visible in the history). Defaults to `\"\"`."
}

variable "crds_helm_lint" {
  type        = bool
  default     = null
  description = "Run the Helm chart linter during the plan. Defaults to `false`."
}

variable "crds_helm_set_sensitive" {
  type        = map(any)
  default     = null
  description = "Value block with custom sensitive values to be merged with the values yaml that won't be exposed in the plan's diff. Defaults to `{}`."
}

variable "crds_helm_postrender" {
  type        = map(any)
  default     = null
  description = "Value block with a path to a binary file to run after Helm renders the manifest which can alter the manifest contents. Defaults to `{}`."
}
