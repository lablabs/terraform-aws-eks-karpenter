locals {
  crds_enabled = var.enabled && var.crds_enabled

  crds_argo_source_type         = var.crds_argo_source_type != null ? var.crds_argo_source_type : try(local.crds.argo_source_type, "helm")
  crds_argo_source_helm_enabled = local.crds_argo_source_type == "helm"

  crds_argo_name         = var.crds_argo_name != null ? var.crds_argo_name : try(local.crds.argo_name, local.crds.name)
  crds_helm_release_name = var.crds_helm_release_name != null ? var.crds_helm_release_name : try(local.crds.helm_release_name, local.crds.name)

  crds_name = local.crds_argo_source_helm_enabled ? local.crds_helm_release_name : local.crds_argo_name
}

module "crds" {
  source = "git::https://github.com/lablabs/terraform-aws-eks-universal-addon.git//modules/addon?ref=v0.0.18"

  enabled = local.crds_enabled

  # variable priority var.crds_* (provided by the module user) > local.crds.* (universal addon default override) > default (universal addon default)
  namespace = local.addon_namespace # CRDs are cluster-wide resources, but for a Helm release we need a namespace to be the same as the addon itself

  helm_enabled                    = var.crds_helm_enabled != null ? var.crds_helm_enabled : try(local.crds.helm_enabled, null)
  helm_release_name               = local.crds_name
  helm_chart_name                 = var.crds_helm_chart_name != null ? var.crds_helm_chart_name : try(local.crds.helm_chart_name, local.crds.name)
  helm_chart_version              = var.crds_helm_chart_version != null ? var.crds_helm_chart_version : local.crds.helm_chart_version
  helm_atomic                     = var.crds_helm_atomic != null ? var.crds_helm_atomic : try(local.crds.helm_atomic, null)
  helm_cleanup_on_fail            = var.crds_helm_cleanup_on_fail != null ? var.crds_helm_cleanup_on_fail : try(local.crds.helm_cleanup_on_fail, null)
  helm_create_namespace           = var.crds_helm_create_namespace != null ? var.crds_helm_create_namespace : try(local.crds.helm_create_namespace, null)
  helm_dependency_update          = var.crds_helm_dependency_update != null ? var.crds_helm_dependency_update : try(local.crds.helm_dependency_update, null)
  helm_description                = var.crds_helm_description != null ? var.crds_helm_description : try(local.crds.helm_description, null)
  helm_devel                      = var.crds_helm_devel != null ? var.crds_helm_devel : try(local.crds.helm_devel, null)
  helm_disable_openapi_validation = var.crds_helm_disable_openapi_validation != null ? var.crds_helm_disable_openapi_validation : try(local.crds.helm_disable_openapi_validation, null)
  helm_disable_webhooks           = var.crds_helm_disable_webhooks != null ? var.crds_helm_disable_webhooks : try(local.crds.helm_disable_webhooks, null)
  helm_force_update               = var.crds_helm_force_update != null ? var.crds_helm_force_update : try(local.crds.helm_force_update, null)
  helm_keyring                    = var.crds_helm_keyring != null ? var.crds_helm_keyring : try(local.crds.helm_keyring, null)
  helm_lint                       = var.crds_helm_lint != null ? var.crds_helm_lint : try(local.crds.helm_lint, null)
  helm_package_verify             = var.crds_helm_package_verify != null ? var.crds_helm_package_verify : try(local.crds.helm_package_verify, null)
  helm_postrender                 = var.crds_helm_postrender != null ? var.crds_helm_postrender : try(local.crds.helm_postrender, null)
  helm_recreate_pods              = var.crds_helm_recreate_pods != null ? var.crds_helm_recreate_pods : try(local.crds.helm_recreate_pods, null)
  helm_release_max_history        = var.crds_helm_release_max_history != null ? var.crds_helm_release_max_history : try(local.crds.helm_release_max_history, null)
  helm_render_subchart_notes      = var.crds_helm_render_subchart_notes != null ? var.crds_helm_render_subchart_notes : try(local.crds.helm_render_subchart_notes, null)
  helm_replace                    = var.crds_helm_replace != null ? var.crds_helm_replace : try(local.crds.helm_replace, null)
  helm_repo_ca_file               = var.crds_helm_repo_ca_file != null ? var.crds_helm_repo_ca_file : try(local.crds.helm_repo_ca_file, null)
  helm_repo_cert_file             = var.crds_helm_repo_cert_file != null ? var.crds_helm_repo_cert_file : try(local.crds.helm_repo_cert_file, null)
  helm_repo_key_file              = var.crds_helm_repo_key_file != null ? var.crds_helm_repo_key_file : try(local.crds.helm_repo_key_file, null)
  helm_repo_password              = var.crds_helm_repo_password != null ? var.crds_helm_repo_password : try(local.crds.helm_repo_password, null)
  helm_repo_url                   = var.crds_helm_repo_url != null ? var.crds_helm_repo_url : local.crds.helm_repo_url
  helm_repo_username              = var.crds_helm_repo_username != null ? var.crds_helm_repo_username : try(local.crds.helm_repo_username, null)
  helm_reset_values               = var.crds_helm_reset_values != null ? var.crds_helm_reset_values : try(local.crds.helm_reset_values, null)
  helm_reuse_values               = var.crds_helm_reuse_values != null ? var.crds_helm_reuse_values : try(local.crds.helm_reuse_values, null)
  helm_set_sensitive              = var.crds_helm_set_sensitive != null ? var.crds_helm_set_sensitive : try(local.crds.helm_set_sensitive, null)
  helm_skip_crds                  = var.crds_helm_skip_crds != null ? var.crds_helm_skip_crds : try(local.crds.helm_skip_crds, null)
  helm_timeout                    = var.crds_helm_timeout != null ? var.crds_helm_timeout : try(local.crds.helm_timeout, null)
  helm_wait                       = var.crds_helm_wait != null ? var.crds_helm_wait : try(local.crds.helm_wait, null)
  helm_wait_for_jobs              = var.crds_helm_wait_for_jobs != null ? var.crds_helm_wait_for_jobs : try(local.crds.helm_wait_for_jobs, null)

  argo_source_type            = local.crds_argo_source_type
  argo_source_repo_url        = var.crds_argo_source_repo_url != null ? var.crds_argo_source_repo_url : try(local.crds.argo_source_repo_url, null)
  argo_source_target_revision = var.crds_argo_source_target_revision != null ? var.crds_argo_source_target_revision : try(local.crds.argo_source_target_revision, null)
  argo_source_path            = var.crds_argo_source_path != null ? var.crds_argo_source_path : try(local.crds.argo_source_path, null)

  argo_apiversion                                        = var.crds_argo_apiversion != null ? var.crds_argo_apiversion : try(local.crds.argo_apiversion, null)
  argo_destination_server                                = var.crds_argo_destination_server != null ? var.crds_argo_destination_server : try(local.crds.argo_destination_server, null)
  argo_enabled                                           = var.crds_argo_enabled != null ? var.crds_argo_enabled : try(local.crds.argo_enabled, null)
  argo_helm_enabled                                      = var.crds_argo_helm_enabled != null ? var.crds_argo_helm_enabled : try(local.crds.argo_helm_enabled, null)
  argo_helm_values                                       = var.crds_argo_helm_values != null ? var.crds_argo_helm_values : try(local.crds.argo_helm_values, null)
  argo_helm_wait_backoff_limit                           = var.crds_argo_helm_wait_backoff_limit != null ? var.crds_argo_helm_wait_backoff_limit : try(local.crds.argo_helm_wait_backoff_limit, null)
  argo_helm_wait_node_selector                           = var.crds_argo_helm_wait_node_selector != null ? var.crds_argo_helm_wait_node_selector : try(local.crds.argo_helm_wait_node_selector, null)
  argo_helm_wait_timeout                                 = var.crds_argo_helm_wait_timeout != null ? var.crds_argo_helm_wait_timeout : try(local.crds.argo_helm_wait_timeout, null)
  argo_helm_wait_tolerations                             = var.crds_argo_helm_wait_tolerations != null ? var.crds_argo_helm_wait_tolerations : try(local.crds.argo_helm_wait_tolerations, null)
  argo_helm_wait_kubectl_version                         = var.crds_argo_helm_wait_kubectl_version != null ? var.crds_argo_helm_wait_kubectl_version : try(local.crds.argo_helm_wait_kubectl_version, null)
  argo_info                                              = var.crds_argo_info != null ? var.crds_argo_info : try(local.crds.argo_info, null)
  argo_kubernetes_manifest_computed_fields               = var.crds_argo_kubernetes_manifest_computed_fields != null ? var.crds_argo_kubernetes_manifest_computed_fields : try(local.crds.argo_kubernetes_manifest_computed_fields, null)
  argo_kubernetes_manifest_field_manager_force_conflicts = var.crds_argo_kubernetes_manifest_field_manager_force_conflicts != null ? var.crds_argo_kubernetes_manifest_field_manager_force_conflicts : try(local.crds.argo_kubernetes_manifest_field_manager_force_conflicts, null)
  argo_kubernetes_manifest_field_manager_name            = var.crds_argo_kubernetes_manifest_field_manager_name != null ? var.crds_argo_kubernetes_manifest_field_manager_name : try(local.crds.argo_kubernetes_manifest_field_manager_name, null)
  argo_kubernetes_manifest_wait_fields                   = var.crds_argo_kubernetes_manifest_wait_fields != null ? var.crds_argo_kubernetes_manifest_wait_fields : try(local.crds.argo_kubernetes_manifest_wait_fields, null)
  argo_metadata                                          = var.crds_argo_metadata != null ? var.crds_argo_metadata : try(local.crds.argo_metadata, null)
  argo_name                                              = local.crds_name
  argo_namespace                                         = var.crds_argo_namespace != null ? var.crds_argo_namespace : try(local.crds.argo_namespace, null)
  argo_project                                           = var.crds_argo_project != null ? var.crds_argo_project : try(local.crds.argo_project, null)
  argo_spec                                              = var.crds_argo_spec != null ? var.crds_argo_spec : try(local.crds.argo_spec, null)
  argo_spec_override                                     = var.crds_argo_spec_override != null ? var.crds_argo_spec_override : try(local.crds.argo_spec_override, null)
  argo_sync_policy                                       = var.crds_argo_sync_policy != null ? var.crds_argo_sync_policy : try(local.crds.argo_sync_policy, null)
  argo_operation                                         = var.crds_argo_operation != null ? var.crds_argo_operation : try(local.crds.argo_operation, null)

  settings = var.crds_settings != null ? var.crds_settings : try(local.crds.settings, null)
  values   = one(data.utils_deep_merge_yaml.crds_values[*].output)
}

data "utils_deep_merge_yaml" "crds_values" {
  count = local.crds_enabled ? 1 : 0

  input = compact([
    local.crds_values,
    var.crds_values
  ])
}

output "crds" {
  description = "The CRDs module outputs"
  value       = module.crds
}
