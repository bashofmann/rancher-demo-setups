terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.22.2"
    }
  }
}
provider "rancher2" {
  api_url    = var.rancher_url
  insecure   = true
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
}

resource "rancher2_cloud_credential" "foo-google" {
  name        = "bhofmann-google"
  description = "Terraform cloudCredential acceptance test"
  google_credential_config {
    auth_encoded_json = file(var.gcp_credentials_file)
  }
}

resource "rancher2_cluster" "foo" {
  name        = "bhofmann-gke"
  description = "Terraform GKE cluster"

  gke_config_v2 {
    name                     = "foo"
    google_credential_secret = rancher2_cloud_credential.foo-google.id
    project_id               = "rancher-dev"
    zone                     = "us-central1-c"
    kubernetes_version       = "1.21.5-gke.1302"
    network                  = "projects/rancher-dev/global/networks/bhofmann-vpc-test"
    subnetwork               = "projects/rancher-dev/regions/us-central1/subnetworks/bhofmann-nodes"

    ip_allocation_policy {
      cluster_secondary_range_name  = "pods"
      services_secondary_range_name = "services"
    }

    master_authorized_networks_config {
      cidr_blocks {
        cidr_block   = "10.0.0.0/8"
        display_name = "testblock"
      }
      enabled = true
    }

    private_cluster_config {
      master_ipv4_cidr_block  = "10.200.221.208/28"
      enable_private_endpoint = true
      enable_private_nodes    = true
    }

    node_pools {
      initial_node_count  = 1
      max_pods_constraint = 110
      name                = "testnodepool"
      version             = "1.21.5-gke.1302"
    }
  }
}