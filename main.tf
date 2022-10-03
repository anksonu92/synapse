resource "random_integer" "suffix" {
  min = 1
  max = 9999

  keepers = {
    resource_group_name = var.resource_group_name
  }
}
