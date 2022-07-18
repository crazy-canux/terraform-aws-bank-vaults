resource "vault_policy" "k8s_policies" {
  for_each = { for policy in local.policies : policy.name => policy }
  name     = each.key
  policy   = each.value.hcl
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
