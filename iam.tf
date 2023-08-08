data "kubernetes_service_account" "webhook_admin" {
  metadata {
    name      = var.service_account
    namespace = var.namespace
  }

  depends_on = [
    helm_release.vault_secrets_webhook
  ]
}

data "kubernetes_secret" "webhook_admin_token" {
  metadata {
    name      = data.kubernetes_service_account.webhook_admin.default_secret_name
    namespace = var.namespace
  }
}

resource "vault_policy" "k8s_policies" {
  for_each = { for policy in local.policies : policy.name => policy }
  name     = each.key
  policy   = each.value.hcl
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "${var.project}/${var.cluster_name}"
}

resource "vault_kubernetes_auth_backend_config" "default" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = data.aws_eks_cluster.default.endpoint
  kubernetes_ca_cert     = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token_reviewer_jwt     = data.kubernetes_secret.webhook_admin_token.data.token
  disable_iss_validation = "true"
}

resource "vault_kubernetes_auth_backend_role" "webhook_admin" {
  for_each                         = { for mapping in local.mappings : mapping.name => mapping }
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = each.value.name
  bound_service_account_names      = each.value.service_accounts
  bound_service_account_namespaces = each.value.namespaces
  token_ttl                        = each.value.ttl
  token_policies                   = each.value.policies
}
