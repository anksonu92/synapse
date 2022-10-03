variable "resource_group_name" {
  description = "The name of the resource group where modules resources will be deployed. The resource group location will be used for all resources in this module as well."
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the Key Vault used for all secrets/keys and encryption operations."
  type        = string
}

variable "key_vault_linked_service" {
  description = "An Object representing the Key Vault used for Synapse Workspace Linked Service."
  type = object({
    name = string
    uri  = string
  })
}

variable "datalake_id" {
  description = "The ID of the Storage Account Datalake used for all Workspace datalake storage"
  type        = string
}

variable "datalake_container_id" {
  description = "The ID of the Storage Account Datalake Container used for Workspace datalake storage"
  type        = string
}

variable "datalake_linked_service" {
  description = "An Object representing the Datalake used as a Workspace Linked Service."
  type = object({
    name         = string
    dfs_endpoint = string
  })
}

variable "name" {
  description = "Name of the Azure Synapse Analytics workspace"
  type        = string

  default = "lens-synapse"
}

variable "admin_name" {
  description = "Name of the Azure Synapse Analytics workspace Administrator"
  type        = string

  default = "synapseAdminUser"
}

variable "spark_pool" {
  description = "An object containing the Synapse Spark Pool config."
  type = object({
    name             = string,
    node_size_family = string,
    node_size        = string
  })

  default = {
    name             = "dataEngineering",
    node_size_family = "MemoryOptimized",
    node_size        = "Small"
  }
}

variable "sql_pool" {
  description = "An object containing the Synapse SQL Pool config."
  type = object({
    name     = string,
    sku_name = string
  })

  default = {
    name     = "mdw",
    sku_name = "DW100c"
  }
}

variable "firewall_rules" {
  description = "A map of objects representing firewall rules to configure on the synapse workspace. Set start ip to '0.0.0.0' and end ip to '255.255.255.255' to allow access from the entire internet. *Note* this is NOT ADVISED IN PRODUCTION ENVIRONMENTS"
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))

  default = {}
}

variable "enable_private_networking" {
  description = "If enabled, private networking will disable internet access to all resources contained within the module. This change requires either an exception list of allowed IPs (including build agents where Terraform is executed!) or that the burden of connectivity amongst all pieces of the infrastructure has been addressed. Defaults to 'false' for the aforementioned reasons. Only set to 'true' if you understand these caveats."
  type        = bool
  default     = false
}

variable "role_assignments" {
  description = "A map of objects representing the role and object id assignments. Valid role names are 'Workspace Admin', 'Apache Spark Admin', or 'Sql Admin'."
  type = map(object({
    object_id = string
    role_name = string
  }))

  default = {}

  validation {
    condition = can({ for k, v in var.role_assignments : k => contains([
      "Workspace Admin",
      "Apache Spark Admin",
      "Sql Admin"
    ], v.role_name) })

    error_message = "Role assignment names can be one of 'Workspace Admin', 'Apache Spark Admin', or 'Sql Admin'."
  }
}

variable "tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default = {
    Team        = "analytics",
    Application = "analytics",
    Department  = "it"
  }
}
