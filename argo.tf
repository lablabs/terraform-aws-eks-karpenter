locals {
  argo_application_metadata = {
    "labels" : try(var.argo_metadata.labels, {}),
    "annotations" : try(var.argo_metadata.annotations, {}),
    "finalizers" : try(var.argo_metadata.finalizers, [])
  }
  argo_application_values = {
    "project" : var.argo_project
    "source" : {
      "repoURL" : var.helm_repo_oci ? local.helm_repo_url : "https://${local.helm_repo_url}"
      "chart" : var.helm_chart_name
      "targetRevision" : var.helm_chart_version
      "helm" : merge(
        {
          "releaseName" : var.helm_release_name
          "values" : var.enabled ? data.utils_deep_merge_yaml.values[0].output : ""
          "skipCrds" : true # CRDs are installed in a separate ArgoCD Application
        },
        length(var.settings) > 0 ? {
          "parameters" : [for k, v in var.settings : tomap({ "forceString" : true, "name" : k, "value" : v })]
        } : {}
      )
    }
    "destination" : {
      "server" : var.argo_destination_server
      "namespace" : var.namespace
    }
    "syncPolicy" : var.argo_sync_policy
    "info" : var.argo_info
  }
}

resource "kubernetes_manifest" "controller" {
  count = var.enabled && var.argo_enabled && !var.argo_helm_enabled ? 1 : 0
  manifest = {
    "apiVersion" = var.argo_apiversion
    "kind"       = "Application"
    "metadata" = merge(
      local.argo_application_metadata,
      { "name" = var.helm_release_name },
      { "namespace" = var.argo_namespace },
    )
    "spec" = merge(
      local.argo_application_values,
      var.argo_spec
    )
  }
  computed_fields = var.argo_kubernetes_manifest_computed_fields

  field_manager {
    name            = var.argo_kubernetes_manifest_field_manager_name
    force_conflicts = var.argo_kubernetes_manifest_field_manager_force_conflicts
  }

  wait {
    fields = var.argo_kubernetes_manifest_wait_fields
  }

  depends_on = [
    kubernetes_manifest.crds
  ]
}
