variable "chart_repo_url" {
  description = "URL to repository containing the vault-secrets-webhook helm chart"
  type        = string
  default     = "https://kubernetes-charts.banzaicloud.com"
}

variable "helm_deployment_name" {
  description = "Name for helm deployment"
  type        = string
  default     = "banzai-vault-webhook"
}

variable "helm_chart_version" {
  description = "Version of the vault-secrets-webhook chart"
  type        = string
  default     = "1.11.1"
}

var "vault_address" {
  type        = string
  description = "vault server"
}

variable "namespace" {
  description = "Name for vault-secrets-webhook namespace"
  type        = string
  default     = "vault-secrets-webhook"
}

variable "service_account" {
  description = "Name for vault-secrets-webhook namespace"
  type        = string
  default     = "vault-webhook-admin"
}

variable "webhook_vault_base_policy" {
  description = "Default policy for the webhook's service acccount in vault"
  type        = string
  default     = ""
}


variable "helm_values" {
  description = "Values for vault-secrets-webhook Helm chart in raw YAML. If none specified, module will add its own set of default values"
  type        = list(string)
  default     = []
}

variable "extra_set_values" {
  description = "Specific values to override in the vault-secrets-webhook Helm chart (overrides corresponding values in the helm-value.yaml file within the module)"
  type = list(object({
    name  = string
    value = any
    type  = string
    })
  )
  default = []
}

variable "project" {
  description = "Name top level project in vault"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "vault_policies" {
  description = "Specific values to override in the vault-secrets-webhook Helm chart (overrides corresponding values in the helm-value.yaml file within the module)"
  type = list(object({
    name = string
    hcl  = string
    })
  )
  default = []
}

variable "extra_sa_mappings" {
  description = "Specific values to override in the vault-secrets-webhook Helm chart (overrides corresponding values in the helm-value.yaml file within the module)"
  type = list(object({
    name             = string
    namespaces       = list(string)
    service_accounts = list(string)
    policies         = list(string)
    ttl              = number
    })
  )
  default = []
}
