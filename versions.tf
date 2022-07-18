terraform {
  required_version = ">= 1.1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.75.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 1.3.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.6.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.3.0"
    }
  }
}
