
# terraform bank vaults

provision vault-secrets-webhook to EKS.

## HowTo

    module "secrets_webhook" {
      source               = "crazy-canux/vaults/bank"
      version              = "0.1.0"      
      cluster_name       = local.cluster_name
      project            = local.vault_project
      helm_chart_version = local.helm_chart_version

      vault_policies = [
        {
          name = "${local.vault_project}/${local.vault_role_name}"
          hcl  = <<-EOT
          path "${local.vault_project}/*" {
            capabilities = ["read", "list"]
          }
          EOT
        }
      ]
      extra_sa_mappings = [
        {
          name             = local.vault_role_name
          namespaces       = [local.namespace]
          service_accounts = [local.service_account]
          policies         = ["${local.vault_project}/${local.vault_role_name}"]
          ttl              = 7200
        }
      ]
    }
