terraform {
  required_version = ">= 0.14.8"

  required_providers {
    time = {
      source  = "registry.terraform.io/hashicorp/time"
      version = "~> 0.7"
    }
    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "~> 3.0"
    }
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "~> 3.9"
    }
  }
}
