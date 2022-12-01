resource "rancher2_cloud_credential" "bhofmann-azure" {
  name = "bhofmann-azure"
  azure_credential_config {
    client_id  = var.azure_client_id
    client_secret = var.azure_client_secret
    subscription_id = var.azure_subscription_id
  }
}

resource "rancher2_cluster" "bhofmann-aks" {
  name        = "bhofmann-aks"
  aks_config_v2 {
    cloud_credential_id = rancher2_cloud_credential.bhofmann-azure.id
    resource_group      = "bhofmann-aks"
    resource_location   = var.azure_location
    imported = true
  }
  fleet_workspace_name = "fleet-other"
}
