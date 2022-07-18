locals {
  vault_role_name = "${var.cluster_name}_${var.namespace}_${var.service_account}"

  mappings = concat(var.extra_sa_mappings, [{
    name             = local.vault_role_name
    namespaces       = [var.namespace]
    service_accounts = [var.service_account]
    policies         = ["${var.project}/${local.vault_role_name}"]
  ttl = 3600 }])

  policies = concat(var.vault_policies, [{
    name = "${var.project}/${local.vault_role_name}"
    hcl  = length(var.webhook_vault_base_policy) > 0 ? var.webhook_vault_base_policy : <<-EOT
    path "${var.project}/*" {
      capabilities = ["read", "list"]
    }
    EOT
  }])
}

# Data resources to retrieve data for providers
data "aws_eks_cluster" "default" {
  name = var.cluster_name
}

####################
# resource/module
####################

# Create namespace
resource "kubernetes_namespace" "webhook_namespace" {
  metadata {
    name = var.namespace
  }
}

# Deploy helm chart
resource "helm_release" "vault_secrets_webhook" {
  name       = var.helm_deployment_name
  repository = var.chart_repo_url
  chart      = "vault-secrets-webhook"
  version    = var.helm_chart_version
  namespace  = var.namespace
  values     = length(var.helm_values) > 0 ? var.helm_values : ["${file("${path.module}/helm-values.yaml")}"]
  set {
    name  = "env.VAULT_ADDR"
    value = var.vault_address
  }
  set {
    name  = "env.VAULT_PATH"
    value = "${var.project}/${var.cluster_name}"
  }
  set {
    name  = "env.VAULT_ENV_PASSTHROUGH"
    value = "VAULT_ADDR,VAULT_PATH,VAULT_ROLE"
  }
  set {
    name  = "securityContext.runAsUser"
    value = 1000570001
  }
  set {
    name  = "configMapMutation"
    value = true
  }
  set {
    name  = "serviceAccount.name"
    value = var.service_account
  }
  dynamic "set" {
    for_each = var.extra_set_values
    content {
      name  = set.value.name
      value = set.value.value
      type  = set.value.type
    }
  }
  depends_on = [
    kubernetes_namespace.webhook_namespace
  ]
}

resource "kubernetes_cluster_role_binding_v1" "vault_auth_delegator" {
  metadata {
    name = "vault-auth:${var.namespace}:${var.service_account}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.service_account
    namespace = var.namespace
  }
}


