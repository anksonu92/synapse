locals {
  synapse_implicit_firewall_rules = {
    AllowAllWindowsAzureIps = {
      start_ip_address = "0.0.0.0"
      end_ip_address   = "0.0.0.0"
    }
    ClientIP-ProvisioningUser = {
      start_ip_address = chomp(data.http.myip.body)
      end_ip_address   = chomp(data.http.myip.body)
    }
  }

  synapse_firewall_rules = merge(var.firewall_rules, local.synapse_implicit_firewall_rules)

}
