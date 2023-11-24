locals {
  crds_argo_application_enabled = var.enabled && var.argo_enabled && !var.argo_helm_enabled && !var.helm_skip_crds
  crds_argo_application_metadata = {
    "labels" : try(var.crds_argo_metadata.labels, {}),
    "annotations" : try(var.crds_argo_metadata.annotations, {}),
    "finalizers" : try(var.crds_argo_metadata.finalizers, [])
  }
  crds_argo_application_values = {
    "project" : var.argo_project
    "source" : {
      "repoURL" : var.helm_repo_oci ? local.helm_repo_url : "https://${local.helm_repo_url}"
      "chart" : var.crds_helm_chart_name
      "targetRevision" : var.crds_helm_chart_version
      "helm" : merge(
        {
          "releaseName" : var.crds_helm_release_name
          "values" : var.enabled ? data.utils_deep_merge_yaml.crds_values[0].output : ""
        },
        length(var.crds_settings) > 0 ? {
          "parameters" : [for k, v in var.crds_settings : tomap({ "forceString" : true, "name" : k, "value" : v })]
        } : {}
      )
    }
    "destination" : {
      "server" : var.argo_destination_server
      "namespace" : var.namespace
    }
    "syncPolicy" : var.crds_argo_sync_policy
    "info" : var.argo_info
  }
  crds_argo_kubernetes_manifest_wait_fields = merge(
    {
      "status.sync.status"   = "Synced"
      "status.health.status" = "Healthy"
    },
    var.crds_argo_kubernetes_manifest_wait_fields
  )
}

resource "kubernetes_manifest" "crds" {
  count = local.crds_argo_application_enabled ? 1 : 0
  manifest = {
    "apiVersion" = var.argo_apiversion
    "kind"       = "Application"
    "metadata" = merge(
      local.crds_argo_application_metadata,
      { "name" = var.crds_helm_release_name },
      { "namespace" = var.argo_namespace },
    )
    "spec" = merge(
      local.crds_argo_application_values,
      var.crds_argo_spec
    )
  }
  computed_fields = var.crds_argo_kubernetes_manifest_computed_fields

  field_manager {
    name            = var.crds_argo_kubernetes_manifest_field_manager_name
    force_conflicts = var.crds_argo_kubernetes_manifest_field_manager_force_conflicts
  }

  wait {
    fields = local.crds_argo_kubernetes_manifest_wait_fields
  }
}
