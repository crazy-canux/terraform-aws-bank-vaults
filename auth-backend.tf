resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "${var.project}/${var.cluster_name}"
}

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

resource "vault_kubernetes_auth_backend_config" "default" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = data.aws_eks_cluster.default.endpoint
  kubernetes_ca_cert     = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token_reviewer_jwt     = data.kubernetes_secret.webhook_admin_token.data.token
  disable_iss_validation = "true"
}
