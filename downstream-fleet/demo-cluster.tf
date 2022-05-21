resource "rancher2_cluster" "fleet_0" {
  name = "${var.prefix}-fleet-0"
  labels = {
    cpu      = "amd"
    location = "central"
    distro   = "k3s"
  }
}
resource "rancher2_cluster" "fleet_1" {
  name = "${var.prefix}-fleet-1"
  labels = {
    cpu      = "amd"
    location = "west"
    distro   = "k3s"
  }
}
resource "rancher2_cluster" "fleet_2" {
  name = "${var.prefix}-fleet-2"
  labels = {
    cpu      = "arm"
    location = "central"
    distro   = "k3s"
  }
}

resource "null_resource" "registration_0" {
  depends_on = [
    null_resource.k3s_0,
  ]
  provisioner "local-exec" {
    command = rancher2_cluster.fleet_0.cluster_registration_token[0].command
    environment = {
      KUBECONFIG = "${path.module}/kubeconfig_0"
    }
  }
}
resource "null_resource" "registration_1" {
  depends_on = [
    null_resource.k3s_1,
  ]
  provisioner "local-exec" {
    command = rancher2_cluster.fleet_1.cluster_registration_token[0].command
    environment = {
      KUBECONFIG = "${path.module}/kubeconfig_1"
    }
  }
}
resource "null_resource" "registration_2" {
  depends_on = [
    null_resource.k3s_2,
  ]
  provisioner "local-exec" {
    command = rancher2_cluster.fleet_2.cluster_registration_token[0].command
    environment = {
      KUBECONFIG = "${path.module}/kubeconfig_2"
    }
  }
}

data "rancher2_principal" "rancher_standard" {
  name = "RancherStandard"
  type = "group"
}

data "rancher2_role_template" "cluster_owner" {
  name = "Cluster Owner"
  context = "cluster"
}

resource "rancher2_cluster_role_template_binding" "rancher_standard_0" {
  name = "rancher-standard"
  cluster_id = rancher2_cluster.fleet_0.id
  role_template_id = data.rancher2_role_template.cluster_owner.id
  group_principal_id = data.rancher2_principal.rancher_standard.id
}

resource "rancher2_cluster_role_template_binding" "rancher_standard_1" {
  name = "rancher-standard"
  cluster_id = rancher2_cluster.fleet_1.id
  role_template_id = data.rancher2_role_template.cluster_owner.id
  group_principal_id = data.rancher2_principal.rancher_standard.id
}

resource "rancher2_cluster_role_template_binding" "rancher_standard_2" {
  name = "rancher-standard"
  cluster_id = rancher2_cluster.fleet_2.id
  role_template_id = data.rancher2_role_template.cluster_owner.id
  group_principal_id = data.rancher2_principal.rancher_standard.id
}