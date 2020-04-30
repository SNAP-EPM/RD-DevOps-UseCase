resource "azurerm_resource_group" "aksk8" {
  location = var.location
  name = join("-",[var.prefix,"rg"])
}

resource "azurerm_kubernetes_cluster" "aksk8" {
  dns_prefix = var.prefix
  location = var.location
  name = join("",[var.prefix,"aks","cluster"])
  resource_group_name = azurerm_resource_group.aksk8.name

  default_node_pool {
    name = "agentpool"
    node_count      = var.agent_count
    vm_size = "Standard_DS2_v2"
  }

  service_principal {
    client_id = var.client_id
    client_secret = var.client_secret
  }
}
terraform {
  backend "azurerm" {
    resource_group_name   = "Rd-devops"
    storage_account_name  = "rddevopsdiag111"
    container_name        = "terraform"
    key                   = "terraform.tfstate"
  }
}
