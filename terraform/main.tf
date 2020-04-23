resource "azurerm_resource_group" "k8s" {
    name     = "${var.prefix}-rg"
    location = var.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = "${var.prefix}-cluster"
    location            = azurerm_resource_group.k8s.location
    resource_group_name = azurerm_resource_group.k8s.name
    dns_prefix          = var.prefix

    default_node_pool {
        name            = "agentpool"
        node_count      = var.agent_count
        vm_size         = "Standard_DS2_v2"
    }

    service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    }
}
