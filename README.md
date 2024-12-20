# AWS EKS Karpenter Terraform module

[<img src="https://lablabs.io/static/ll-logo.png" width=350px>](https://lablabs.io/)

We help companies build, run, deploy and scale software and infrastructure by embracing the right technologies and principles. Check out our website at https://lablabs.io/

---

[![Terraform validate](https://github.com/lablabs/terraform-aws-eks-karpenter/actions/workflows/validate.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-karpenter/actions/workflows/validate.yaml)
[![pre-commit](https://github.com/lablabs/terraform-aws-eks-karpenter/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-karpenter/actions/workflows/pre-commit.yml)

## Description

A terraform module to deploy the Karpenter on Amazon EKS cluster.

## Related Projects

Check out other [terraform kubernetes addons](https://github.com/orgs/lablabs/repositories?q=terraform-aws-eks&type=public&language=&sort=).

## Deployment methods

### Helm
Deploy Helm chart via Helm resource (default method, set `enabled = true`)

### Argo Kubernetes
Deploy Helm chart as ArgoCD Application via Kubernetes manifest resource (set `enabled = true` and `argo_enabled = true`)

> **Warning**
>
> When deploying with ArgoCD application, Kubernetes terraform provider requires access to Kubernetes cluster API during plan time. This introduces potential issue when you want to deploy the cluster with this addon at the same time, during the same Terraform run.
>
> To overcome this issue, the module deploys the ArgoCD application object using the Helm provider, which does not require API access during plan. If you want to deploy the application using this workaround, you can set the `argo_helm_enabled` variable to `true`.

### Argo Helm
Deploy Helm chart as ArgoCD Application via Helm resource (set `enabled = true`, `argo_enabled = true` and `argo_helm_enabled = true`)

## AWS IAM resources

To disable of creation IRSA role and IRSA policy, set `irsa_role_create = false` and `irsa_policy_enabled = false`, respectively

### Role assuming
To assume role set `irsa_assume_role_enabled = true` and specify `irsa_assume_role_arn` variable

## Repository configuration

In variable `helm_repo_oci` you can switch between OCI and non-OCI repositories types. Due to non standardized input of repository format between argocd and helm you must use correct url format for each type.

For helm_repo_oci=`true` in variable `helm_repo_url` use format without protocol prefix `public.ecr.aws` . If you put there `https` prefix it will be stripped automatically as fails safe mechanism .

For helm_repo_oci=`false`  in variable `helm_repo_url` use format including protocol prefix like `https://chartmuseum.example.com`

## Spot interruption testing

To test whether karpenter integration with SQS is working properly you can send Spot interruption Warning message to SQS queue.
For more information about correct time format etc. check the documentation linked below.

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-instance-termination-notices.html#ec2-spot-instance-interruption-warning-event


```json
{
    "version": "0",
    "id": "12345678-1234-1234-1234-123456789012",
    "detail-type": "EC2 Spot Instance Interruption Warning",
    "source": "aws.ec2",
    "account": "123456789012",
    "time": "2023-03-26T22:22:33+02:00",
    "region": "eu-central-1",
    "resources": ["arn:aws:ec2:eu-central-1:123456789012:instance/i-00c05af08b38bb912"],
    "detail": {
        "instance-id": "i-00c05af08b38bb912",
        "instance-action": "action"
    }
}
```

## Examples

See [Basic example](examples/basic/README.md) for further information.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.19.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.6.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.20.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.0 |
| <a name="requirement_utils"></a> [utils](#requirement\_utils) | >= 0.17.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sqs_queue.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [helm_release.argo_application](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.crds](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.crds_argo_application](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_job.crds_helm_argo_application_wait](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job) | resource |
| [kubernetes_job.helm_argo_application_wait](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job) | resource |
| [kubernetes_manifest.controller](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.crds](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_role.crds_helm_argo_application_wait](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role.helm_argo_application_wait](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role_binding.crds_helm_argo_application_wait](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_role_binding.helm_argo_application_wait](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_service_account.crds_helm_argo_application_wait](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.helm_argo_application_wait](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_iam_policy_document.queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this_irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [utils_deep_merge_yaml.argo_helm_values](https://registry.terraform.io/providers/cloudposse/utils/latest/docs/data-sources/deep_merge_yaml) | data source |
| [utils_deep_merge_yaml.crds_argo_helm_values](https://registry.terraform.io/providers/cloudposse/utils/latest/docs/data-sources/deep_merge_yaml) | data source |
| [utils_deep_merge_yaml.crds_values](https://registry.terraform.io/providers/cloudposse/utils/latest/docs/data-sources/deep_merge_yaml) | data source |
| [utils_deep_merge_yaml.values](https://registry.terraform.io/providers/cloudposse/utils/latest/docs/data-sources/deep_merge_yaml) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_identity_oidc_issuer"></a> [cluster\_identity\_oidc\_issuer](#input\_cluster\_identity\_oidc\_issuer) | The OIDC Identity issuer for the cluster | `string` | n/a | yes |
| <a name="input_cluster_identity_oidc_issuer_arn"></a> [cluster\_identity\_oidc\_issuer\_arn](#input\_cluster\_identity\_oidc\_issuer\_arn) | The OIDC Identity issuer ARN for the cluster that can be used to associate IAM roles with a service account | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS Cluster ID for the cluster that can be used to join cluster node pool | `string` | n/a | yes |
| <a name="input_argo_apiversion"></a> [argo\_apiversion](#input\_argo\_apiversion) | ArgoCD Appliction apiVersion | `string` | `"argoproj.io/v1alpha1"` | no |
| <a name="input_argo_destination_server"></a> [argo\_destination\_server](#input\_argo\_destination\_server) | Destination server for ArgoCD Application | `string` | `"https://kubernetes.default.svc"` | no |
| <a name="input_argo_enabled"></a> [argo\_enabled](#input\_argo\_enabled) | If set to true, the module will be deployed as ArgoCD application, otherwise it will be deployed as a Helm release | `bool` | `false` | no |
| <a name="input_argo_helm_enabled"></a> [argo\_helm\_enabled](#input\_argo\_helm\_enabled) | If set to true, the ArgoCD Application manifest will be deployed using Kubernetes provider as a Helm release. Otherwise it'll be deployed as a Kubernetes manifest. See Readme for more info | `bool` | `false` | no |
| <a name="input_argo_helm_values"></a> [argo\_helm\_values](#input\_argo\_helm\_values) | Value overrides to use when deploying argo application object with helm | `string` | `""` | no |
| <a name="input_argo_helm_wait_backoff_limit"></a> [argo\_helm\_wait\_backoff\_limit](#input\_argo\_helm\_wait\_backoff\_limit) | Backoff limit for ArgoCD Application Helm release wait job | `number` | `6` | no |
| <a name="input_argo_helm_wait_node_selector"></a> [argo\_helm\_wait\_node\_selector](#input\_argo\_helm\_wait\_node\_selector) | Node selector for ArgoCD Application Helm release wait job | `map(string)` | `{}` | no |
| <a name="input_argo_helm_wait_timeout"></a> [argo\_helm\_wait\_timeout](#input\_argo\_helm\_wait\_timeout) | Timeout for ArgoCD Application Helm release wait job | `string` | `"10m"` | no |
| <a name="input_argo_helm_wait_tolerations"></a> [argo\_helm\_wait\_tolerations](#input\_argo\_helm\_wait\_tolerations) | Tolerations for ArgoCD Application Helm release wait job | `list(any)` | `[]` | no |
| <a name="input_argo_info"></a> [argo\_info](#input\_argo\_info) | ArgoCD info manifest parameter | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | <pre>[<br>  {<br>    "name": "terraform",<br>    "value": "true"<br>  }<br>]</pre> | no |
| <a name="input_argo_kubernetes_manifest_computed_fields"></a> [argo\_kubernetes\_manifest\_computed\_fields](#input\_argo\_kubernetes\_manifest\_computed\_fields) | List of paths of fields to be handled as "computed". The user-configured value for the field will be overridden by any different value returned by the API after apply. | `list(string)` | <pre>[<br>  "metadata.labels",<br>  "metadata.annotations",<br>  "metadata.finalizers"<br>]</pre> | no |
| <a name="input_argo_kubernetes_manifest_field_manager_force_conflicts"></a> [argo\_kubernetes\_manifest\_field\_manager\_force\_conflicts](#input\_argo\_kubernetes\_manifest\_field\_manager\_force\_conflicts) | Forcibly override any field manager conflicts when applying the kubernetes manifest resource | `bool` | `false` | no |
| <a name="input_argo_kubernetes_manifest_field_manager_name"></a> [argo\_kubernetes\_manifest\_field\_manager\_name](#input\_argo\_kubernetes\_manifest\_field\_manager\_name) | The name of the field manager to use when applying the kubernetes manifest resource. Defaults to Terraform | `string` | `"Terraform"` | no |
| <a name="input_argo_kubernetes_manifest_wait_fields"></a> [argo\_kubernetes\_manifest\_wait\_fields](#input\_argo\_kubernetes\_manifest\_wait\_fields) | A map of fields and a corresponding regular expression with a pattern to wait for. The provider will wait until the field matches the regular expression. Use * for any value. | `map(string)` | `{}` | no |
| <a name="input_argo_metadata"></a> [argo\_metadata](#input\_argo\_metadata) | ArgoCD Application metadata configuration. Override or create additional metadata parameters | `any` | <pre>{<br>  "finalizers": [<br>    "resources-finalizer.argocd.argoproj.io"<br>  ]<br>}</pre> | no |
| <a name="input_argo_namespace"></a> [argo\_namespace](#input\_argo\_namespace) | Namespace to deploy ArgoCD application CRD to | `string` | `"argo"` | no |
| <a name="input_argo_project"></a> [argo\_project](#input\_argo\_project) | ArgoCD Application project | `string` | `"default"` | no |
| <a name="input_argo_spec"></a> [argo\_spec](#input\_argo\_spec) | ArgoCD Application spec configuration. Override or create additional spec parameters | `any` | `{}` | no |
| <a name="input_argo_sync_policy"></a> [argo\_sync\_policy](#input\_argo\_sync\_policy) | ArgoCD syncPolicy manifest parameter | `any` | `{}` | no |
| <a name="input_aws_partition"></a> [aws\_partition](#input\_aws\_partition) | AWS partition in which the resources are located. Avaliable values are `aws`, `aws-cn`, `aws-us-gov` | `string` | `"aws"` | no |
| <a name="input_crds_argo_helm_values"></a> [crds\_argo\_helm\_values](#input\_crds\_argo\_helm\_values) | Value overrides to use when deploying argo application object with helm | `string` | `""` | no |
| <a name="input_crds_argo_kubernetes_manifest_computed_fields"></a> [crds\_argo\_kubernetes\_manifest\_computed\_fields](#input\_crds\_argo\_kubernetes\_manifest\_computed\_fields) | List of paths of fields to be handled as "computed". The user-configured value for the field will be overridden by any different value returned by the API after apply. | `list(string)` | <pre>[<br>  "metadata.labels",<br>  "metadata.annotations",<br>  "metadata.finalizers"<br>]</pre> | no |
| <a name="input_crds_argo_kubernetes_manifest_field_manager_force_conflicts"></a> [crds\_argo\_kubernetes\_manifest\_field\_manager\_force\_conflicts](#input\_crds\_argo\_kubernetes\_manifest\_field\_manager\_force\_conflicts) | Forcibly override any field manager conflicts when applying the kubernetes manifest resource | `bool` | `false` | no |
| <a name="input_crds_argo_kubernetes_manifest_field_manager_name"></a> [crds\_argo\_kubernetes\_manifest\_field\_manager\_name](#input\_crds\_argo\_kubernetes\_manifest\_field\_manager\_name) | The name of the field manager to use when applying the kubernetes manifest resource. Defaults to Terraform | `string` | `"Terraform"` | no |
| <a name="input_crds_argo_kubernetes_manifest_wait_fields"></a> [crds\_argo\_kubernetes\_manifest\_wait\_fields](#input\_crds\_argo\_kubernetes\_manifest\_wait\_fields) | A map of fields and a corresponding regular expression with a pattern to wait for. The provider will wait until the field matches the regular expression. Use * for any value. | `map(string)` | `{}` | no |
| <a name="input_crds_argo_metadata"></a> [crds\_argo\_metadata](#input\_crds\_argo\_metadata) | ArgoCD Application metadata configuration. Override or create additional metadata parameters | `any` | <pre>{<br>  "finalizers": [<br>    "resources-finalizer.argocd.argoproj.io"<br>  ]<br>}</pre> | no |
| <a name="input_crds_argo_spec"></a> [crds\_argo\_spec](#input\_crds\_argo\_spec) | ArgoCD Application spec configuration. Override or create additional spec parameters | `any` | `{}` | no |
| <a name="input_crds_argo_sync_policy"></a> [crds\_argo\_sync\_policy](#input\_crds\_argo\_sync\_policy) | ArgoCD syncPolicy manifest parameter | `any` | `{}` | no |
| <a name="input_crds_helm_atomic"></a> [crds\_helm\_atomic](#input\_crds\_helm\_atomic) | If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used | `bool` | `false` | no |
| <a name="input_crds_helm_chart_name"></a> [crds\_helm\_chart\_name](#input\_crds\_helm\_chart\_name) | Helm chart name to be installed | `string` | `"karpenter-crd"` | no |
| <a name="input_crds_helm_chart_version"></a> [crds\_helm\_chart\_version](#input\_crds\_helm\_chart\_version) | Version of the Helm chart | `string` | `"1.0.8"` | no |
| <a name="input_crds_helm_cleanup_on_fail"></a> [crds\_helm\_cleanup\_on\_fail](#input\_crds\_helm\_cleanup\_on\_fail) | Allow deletion of new resources created in this helm upgrade when upgrade fails | `bool` | `false` | no |
| <a name="input_crds_helm_dependency_update"></a> [crds\_helm\_dependency\_update](#input\_crds\_helm\_dependency\_update) | Runs helm dependency update before installing the chart | `bool` | `false` | no |
| <a name="input_crds_helm_description"></a> [crds\_helm\_description](#input\_crds\_helm\_description) | Set helm release description attribute (visible in the history) | `string` | `""` | no |
| <a name="input_crds_helm_devel"></a> [crds\_helm\_devel](#input\_crds\_helm\_devel) | Use helm chart development versions, too. Equivalent to version '>0.0.0-0'. If version is set, this is ignored | `bool` | `false` | no |
| <a name="input_crds_helm_disable_openapi_validation"></a> [crds\_helm\_disable\_openapi\_validation](#input\_crds\_helm\_disable\_openapi\_validation) | If set, the installation process will not validate rendered helm templates against the Kubernetes OpenAPI Schema | `bool` | `false` | no |
| <a name="input_crds_helm_disable_webhooks"></a> [crds\_helm\_disable\_webhooks](#input\_crds\_helm\_disable\_webhooks) | Prevent helm chart hooks from running | `bool` | `false` | no |
| <a name="input_crds_helm_force_update"></a> [crds\_helm\_force\_update](#input\_crds\_helm\_force\_update) | Force helm resource update through delete/recreate if needed | `bool` | `false` | no |
| <a name="input_crds_helm_keyring"></a> [crds\_helm\_keyring](#input\_crds\_helm\_keyring) | Location of public keys used for verification. Used only if helm\_package\_verify is true | `string` | `"~/.gnupg/pubring.gpg"` | no |
| <a name="input_crds_helm_lint"></a> [crds\_helm\_lint](#input\_crds\_helm\_lint) | Run the helm chart linter during the plan | `bool` | `false` | no |
| <a name="input_crds_helm_package_verify"></a> [crds\_helm\_package\_verify](#input\_crds\_helm\_package\_verify) | Verify the package before installing it. Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart | `bool` | `false` | no |
| <a name="input_crds_helm_postrender"></a> [crds\_helm\_postrender](#input\_crds\_helm\_postrender) | Value block with a path to a binary file to run after helm renders the manifest which can alter the manifest contents | `map(any)` | `{}` | no |
| <a name="input_crds_helm_recreate_pods"></a> [crds\_helm\_recreate\_pods](#input\_crds\_helm\_recreate\_pods) | Perform pods restart during helm upgrade/rollback | `bool` | `false` | no |
| <a name="input_crds_helm_release_max_history"></a> [crds\_helm\_release\_max\_history](#input\_crds\_helm\_release\_max\_history) | Maximum number of release versions stored per release | `number` | `0` | no |
| <a name="input_crds_helm_release_name"></a> [crds\_helm\_release\_name](#input\_crds\_helm\_release\_name) | Helm release name | `string` | `"karpenter-crds"` | no |
| <a name="input_crds_helm_render_subchart_notes"></a> [crds\_helm\_render\_subchart\_notes](#input\_crds\_helm\_render\_subchart\_notes) | If set, render helm subchart notes along with the parent | `bool` | `true` | no |
| <a name="input_crds_helm_replace"></a> [crds\_helm\_replace](#input\_crds\_helm\_replace) | Re-use the given name of helm release, only if that name is a deleted release which remains in the history. This is unsafe in production | `bool` | `false` | no |
| <a name="input_crds_helm_reset_values"></a> [crds\_helm\_reset\_values](#input\_crds\_helm\_reset\_values) | When upgrading, reset the values to the ones built into the helm chart | `bool` | `false` | no |
| <a name="input_crds_helm_reuse_values"></a> [crds\_helm\_reuse\_values](#input\_crds\_helm\_reuse\_values) | When upgrading, reuse the last helm release's values and merge in any overrides. If 'helm\_reset\_values' is specified, this is ignored | `bool` | `false` | no |
| <a name="input_crds_helm_set_sensitive"></a> [crds\_helm\_set\_sensitive](#input\_crds\_helm\_set\_sensitive) | Value block with custom sensitive values to be merged with the values yaml that won't be exposed in the plan's diff | `map(any)` | `{}` | no |
| <a name="input_crds_helm_timeout"></a> [crds\_helm\_timeout](#input\_crds\_helm\_timeout) | Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks) | `number` | `300` | no |
| <a name="input_crds_helm_wait"></a> [crds\_helm\_wait](#input\_crds\_helm\_wait) | Will wait until all helm release resources are in a ready state before marking the release as successful. It will wait for as long as timeout | `bool` | `true` | no |
| <a name="input_crds_helm_wait_for_jobs"></a> [crds\_helm\_wait\_for\_jobs](#input\_crds\_helm\_wait\_for\_jobs) | If wait is enabled, will wait until all helm Jobs have been completed before marking the release as successful. It will wait for as long as timeout | `bool` | `false` | no |
| <a name="input_crds_settings"></a> [crds\_settings](#input\_crds\_settings) | Additional helm sets which will be passed to the Helm chart values, see https://github.com/aws/karpenter/tree/main/charts/karpenter-crd | `map(any)` | `{}` | no |
| <a name="input_crds_values"></a> [crds\_values](#input\_crds\_values) | Additional yaml encoded values which will be passed to the Helm chart, see https://github.com/aws/karpenter/tree/main/charts/karpenter-crd | `string` | `""` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Variable indicating whether deployment is enabled | `bool` | `true` | no |
| <a name="input_helm_atomic"></a> [helm\_atomic](#input\_helm\_atomic) | If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used | `bool` | `false` | no |
| <a name="input_helm_chart_name"></a> [helm\_chart\_name](#input\_helm\_chart\_name) | Helm chart name to be installed | `string` | `"karpenter"` | no |
| <a name="input_helm_chart_version"></a> [helm\_chart\_version](#input\_helm\_chart\_version) | Version of the Helm chart | `string` | `"1.0.8"` | no |
| <a name="input_helm_cleanup_on_fail"></a> [helm\_cleanup\_on\_fail](#input\_helm\_cleanup\_on\_fail) | Allow deletion of new resources created in this helm upgrade when upgrade fails | `bool` | `false` | no |
| <a name="input_helm_create_namespace"></a> [helm\_create\_namespace](#input\_helm\_create\_namespace) | Create the namespace if it does not yet exist | `bool` | `true` | no |
| <a name="input_helm_dependency_update"></a> [helm\_dependency\_update](#input\_helm\_dependency\_update) | Runs helm dependency update before installing the chart | `bool` | `false` | no |
| <a name="input_helm_description"></a> [helm\_description](#input\_helm\_description) | Set helm release description attribute (visible in the history) | `string` | `""` | no |
| <a name="input_helm_devel"></a> [helm\_devel](#input\_helm\_devel) | Use helm chart development versions, too. Equivalent to version '>0.0.0-0'. If version is set, this is ignored | `bool` | `false` | no |
| <a name="input_helm_disable_openapi_validation"></a> [helm\_disable\_openapi\_validation](#input\_helm\_disable\_openapi\_validation) | If set, the installation process will not validate rendered helm templates against the Kubernetes OpenAPI Schema | `bool` | `false` | no |
| <a name="input_helm_disable_webhooks"></a> [helm\_disable\_webhooks](#input\_helm\_disable\_webhooks) | Prevent helm chart hooks from running | `bool` | `false` | no |
| <a name="input_helm_force_update"></a> [helm\_force\_update](#input\_helm\_force\_update) | Force helm resource update through delete/recreate if needed | `bool` | `false` | no |
| <a name="input_helm_keyring"></a> [helm\_keyring](#input\_helm\_keyring) | Location of public keys used for verification. Used only if helm\_package\_verify is true | `string` | `"~/.gnupg/pubring.gpg"` | no |
| <a name="input_helm_lint"></a> [helm\_lint](#input\_helm\_lint) | Run the helm chart linter during the plan | `bool` | `false` | no |
| <a name="input_helm_package_verify"></a> [helm\_package\_verify](#input\_helm\_package\_verify) | Verify the package before installing it. Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart | `bool` | `false` | no |
| <a name="input_helm_postrender"></a> [helm\_postrender](#input\_helm\_postrender) | Value block with a path to a binary file to run after helm renders the manifest which can alter the manifest contents | `map(any)` | `{}` | no |
| <a name="input_helm_recreate_pods"></a> [helm\_recreate\_pods](#input\_helm\_recreate\_pods) | Perform pods restart during helm upgrade/rollback | `bool` | `false` | no |
| <a name="input_helm_release_max_history"></a> [helm\_release\_max\_history](#input\_helm\_release\_max\_history) | Maximum number of release versions stored per release | `number` | `0` | no |
| <a name="input_helm_release_name"></a> [helm\_release\_name](#input\_helm\_release\_name) | Helm release name | `string` | `"karpenter"` | no |
| <a name="input_helm_render_subchart_notes"></a> [helm\_render\_subchart\_notes](#input\_helm\_render\_subchart\_notes) | If set, render helm subchart notes along with the parent | `bool` | `true` | no |
| <a name="input_helm_replace"></a> [helm\_replace](#input\_helm\_replace) | Re-use the given name of helm release, only if that name is a deleted release which remains in the history. This is unsafe in production | `bool` | `false` | no |
| <a name="input_helm_repo_ca_file"></a> [helm\_repo\_ca\_file](#input\_helm\_repo\_ca\_file) | Helm repositories cert file | `string` | `""` | no |
| <a name="input_helm_repo_cert_file"></a> [helm\_repo\_cert\_file](#input\_helm\_repo\_cert\_file) | Helm repositories cert file | `string` | `""` | no |
| <a name="input_helm_repo_key_file"></a> [helm\_repo\_key\_file](#input\_helm\_repo\_key\_file) | Helm repositories cert key file | `string` | `""` | no |
| <a name="input_helm_repo_oci"></a> [helm\_repo\_oci](#input\_helm\_repo\_oci) | Whether repo is OCI compatible | `bool` | `true` | no |
| <a name="input_helm_repo_password"></a> [helm\_repo\_password](#input\_helm\_repo\_password) | Password for HTTP basic authentication against the helm repository | `string` | `""` | no |
| <a name="input_helm_repo_url"></a> [helm\_repo\_url](#input\_helm\_repo\_url) | Helm repository | `string` | `"public.ecr.aws"` | no |
| <a name="input_helm_repo_username"></a> [helm\_repo\_username](#input\_helm\_repo\_username) | Username for HTTP basic authentication against the helm repository | `string` | `""` | no |
| <a name="input_helm_reset_values"></a> [helm\_reset\_values](#input\_helm\_reset\_values) | When upgrading, reset the values to the ones built into the helm chart | `bool` | `false` | no |
| <a name="input_helm_reuse_values"></a> [helm\_reuse\_values](#input\_helm\_reuse\_values) | When upgrading, reuse the last helm release's values and merge in any overrides. If 'helm\_reset\_values' is specified, this is ignored | `bool` | `false` | no |
| <a name="input_helm_set_sensitive"></a> [helm\_set\_sensitive](#input\_helm\_set\_sensitive) | Value block with custom sensitive values to be merged with the values yaml that won't be exposed in the plan's diff | `map(any)` | `{}` | no |
| <a name="input_helm_skip_crds"></a> [helm\_skip\_crds](#input\_helm\_skip\_crds) | If set, no CRDs will be installed before helm release | `bool` | `false` | no |
| <a name="input_helm_timeout"></a> [helm\_timeout](#input\_helm\_timeout) | Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks) | `number` | `300` | no |
| <a name="input_helm_wait"></a> [helm\_wait](#input\_helm\_wait) | Will wait until all helm release resources are in a ready state before marking the release as successful. It will wait for as long as timeout | `bool` | `false` | no |
| <a name="input_helm_wait_for_jobs"></a> [helm\_wait\_for\_jobs](#input\_helm\_wait\_for\_jobs) | If wait is enabled, will wait until all helm Jobs have been completed before marking the release as successful. It will wait for as long as timeout | `bool` | `false` | no |
| <a name="input_irsa_additional_policies"></a> [irsa\_additional\_policies](#input\_irsa\_additional\_policies) | Map of the additional policies to be attached to default role. Where key is arbitrary id and value is policy arn. | `map(string)` | `{}` | no |
| <a name="input_irsa_assume_role_arn"></a> [irsa\_assume\_role\_arn](#input\_irsa\_assume\_role\_arn) | Assume role arn. Assume role must be enabled. | `string` | `""` | no |
| <a name="input_irsa_assume_role_enabled"></a> [irsa\_assume\_role\_enabled](#input\_irsa\_assume\_role\_enabled) | Whether IRSA is allowed to assume role defined by irsa\_assume\_role\_arn. | `bool` | `false` | no |
| <a name="input_irsa_policy_enabled"></a> [irsa\_policy\_enabled](#input\_irsa\_policy\_enabled) | Whether to create opinionated policy to allow operations on specified zones in `policy_allowed_zone_ids`. | `bool` | `true` | no |
| <a name="input_irsa_role_create"></a> [irsa\_role\_create](#input\_irsa\_role\_create) | Whether to create IRSA role and annotate service account | `bool` | `true` | no |
| <a name="input_irsa_role_name_prefix"></a> [irsa\_role\_name\_prefix](#input\_irsa\_role\_name\_prefix) | The IRSA role name prefix for karpenter | `string` | `"karpenter-irsa"` | no |
| <a name="input_irsa_tags"></a> [irsa\_tags](#input\_irsa\_tags) | IRSA resources tags | `map(string)` | `{}` | no |
| <a name="input_karpenter_node_role_arns"></a> [karpenter\_node\_role\_arns](#input\_karpenter\_node\_role\_arns) | List of roles arns which can be passed from karpenter service to newly created nodes | `list(any)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The K8s namespace in which the karpenter service account has been created | `string` | `"karpenter"` | no |
| <a name="input_queue_interruption_prefix"></a> [queue\_interruption\_prefix](#input\_queue\_interruption\_prefix) | Custom prefix for karpenter spot interruption queue | `string` | `"interruption-queue"` | no |
| <a name="input_rbac_create"></a> [rbac\_create](#input\_rbac\_create) | Whether to create and use RBAC resources | `bool` | `true` | no |
| <a name="input_rule_interruption_prefix"></a> [rule\_interruption\_prefix](#input\_rule\_interruption\_prefix) | Prefix used for all event bridge rules | `string` | `"Karpenter"` | no |
| <a name="input_service_account_create"></a> [service\_account\_create](#input\_service\_account\_create) | Whether to create Service Account | `bool` | `true` | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | The k8s <$addon-name> service account name | `string` | `"karpenter"` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | Additional helm sets which will be passed to the Helm chart values, see https://artifacthub.io/packages/helm/karpenter/karpenter | `map(any)` | `{}` | no |
| <a name="input_values"></a> [values](#input\_values) | Additional yaml encoded values which will be passed to the Helm chart, see https://artifacthub.io/packages/helm/karpenter/karpenter | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_helm_release_application_metadata"></a> [helm\_release\_application\_metadata](#output\_helm\_release\_application\_metadata) | Argo application helm release attributes |
| <a name="output_helm_release_metadata"></a> [helm\_release\_metadata](#output\_helm\_release\_metadata) | Helm release attributes |
| <a name="output_iam_irsa_role_attributes"></a> [iam\_irsa\_role\_attributes](#output\_iam\_irsa\_role\_attributes) | Karpenter IAM role attributes |
| <a name="output_kubernetes_application_attributes"></a> [kubernetes\_application\_attributes](#output\_kubernetes\_application\_attributes) | Argo kubernetes manifest attributes |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing and reporting issues

Feel free to create an issue in this repository if you have questions, suggestions or feature requests.

### Validation, linters and pull-requests

We want to provide high quality code and modules. For this reason we are using
several [pre-commit hooks](.pre-commit-config.yaml) and
[GitHub Actions workflows](.github/workflows/). A pull-request to the
main branch will trigger these validations and lints automatically. Please
check your code before you will create pull-requests. See
[pre-commit documentation](https://pre-commit.com/) and
[GitHub Actions documentation](https://docs.github.com/en/actions) for further
details.

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
