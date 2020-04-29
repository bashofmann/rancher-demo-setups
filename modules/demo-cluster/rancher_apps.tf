data "rancher2_project" "system" {
  depends_on = [
    rancher2_cluster_sync.demo
  ]
  cluster_id = rancher2_cluster_sync.demo.id
  name       = "System"
}

resource "rancher2_namespace" "longhorn-system" {
  name       = "longhorn-system"
  project_id = data.rancher2_project.system.id
}

resource "rancher2_namespace" "cattle-prometheus" {
  name       = "cattle-prometheus"
  project_id = data.rancher2_project.system.id
}

resource "rancher2_namespace" "istio-system" {
  name       = "istio-system"
  project_id = data.rancher2_project.system.id
}

resource "rancher2_app" "longhorn-system" {
  catalog_name     = "library"
  name             = "longhorn-system"
  project_id       = data.rancher2_project.system.id
  template_name    = "longhorn"
  template_version = "0.8.1"
  target_namespace = rancher2_namespace.longhorn-system.name
  answers = {
    "csi.attacherReplicaCount" = "",
    "csi.kubeletRootDir" = "",
    "csi.provisionerReplicaCount" = "",
    "defaultSettings.backupTarget" = "",
    "defaultSettings.backupTargetCredentialSecret" = "",
    "defaultSettings.backupstorePollInterval" = "300",
    "defaultSettings.createDefaultDiskLabeledNodes" = "false",
    "defaultSettings.defaultDataPath" = "/var/lib/longhorn/",
    "defaultSettings.defaultLonghornStaticStorageClass" = "longhorn-static",
    "defaultSettings.defaultReplicaCount" = "3",
    "defaultSettings.guaranteedEngineCPU" = "0",
    "defaultSettings.registrySecret" = "",
    "defaultSettings.replicaSoftAntiAffinity" = "true",
    "defaultSettings.storageMinimalAvailablePercentage" = "25",
    "defaultSettings.storageOverProvisioningPercentage" = "200",
    "defaultSettings.taintToleration" = "",
    "defaultSettings.upgradeChecker" = "true",
    "image.defaultImage" = "true",
    "ingress.enabled" = "false",
    "persistence.defaultClass" = "true",
    "persistence.defaultClassReplicaCount" = "3",
    "privateRegistry.registryPasswd" = "",
    "privateRegistry.registryUrl" = "",
    "privateRegistry.registryUser" = "",
    "service.ui.type" = "Rancher-Proxy"
  }
  lifecycle {
    ignore_changes = [
      project_id
    ]
  }
}
//
//resource "rancher2_app" "cluster-monitoring" {
//  depends_on = [
//    rancher2_app.monitoring-operator
//  ]
//  catalog_name     = "system-library"
//  name             = "cluster-monitoring"
//  description      = "Rancher Cluster Monitoring"
//  project_id       = data.rancher2_project.system.id
//  template_name    = "rancher-monitoring"
//  template_version = "0.1.0"
//  target_namespace = rancher2_namespace.cattle-prometheus.name
//  answers = {
//    "enabled" = "false",
//    "exporter-coredns.apiGroup" = "monitoring.coreos.com",
//    "exporter-fluentd.apiGroup" = "monitoring.coreos.com",
//    "exporter-fluentd.enabled" = "true",
//    "exporter-kube-controller-manager.apiGroup" = "monitoring.coreos.com",
//    "exporter-kube-controller-manager.enabled" = "true",
//    "exporter-kube-controller-manager.endpoints[0]" = "172.31.17.153",
//    "exporter-kube-controller-manager.endpoints[1]" = "172.31.22.178",
//    "exporter-kube-controller-manager.endpoints[2]" = "172.31.28.182",
//    "exporter-kube-dns.apiGroup" = "monitoring.coreos.com",
//    "exporter-kube-etcd.apiGroup" = "monitoring.coreos.com",
//    "exporter-kube-etcd.certFile" = "/etc/prometheus/secrets/exporter-etcd-cert/kube-etcd-172-31-17-153.pem",
//    "exporter-kube-etcd.enabled" = "true",
//    "exporter-kube-etcd.endpoints[0]" = "172.31.17.153",
//    "exporter-kube-etcd.endpoints[1]" = "172.31.22.178",
//    "exporter-kube-etcd.endpoints[2]" = "172.31.28.182",
//    "exporter-kube-etcd.keyFile" = "/etc/prometheus/secrets/exporter-etcd-cert/kube-etcd-172-31-17-153-key.pem",
//    "exporter-kube-etcd.ports.metrics.port" = "2379",
//    "exporter-kube-scheduler.apiGroup" = "monitoring.coreos.com",
//    "exporter-kube-scheduler.enabled" = "true",
//    "exporter-kube-scheduler.endpoints[0]" = "172.31.17.153",
//    "exporter-kube-scheduler.endpoints[1]" = "172.31.22.178",
//    "exporter-kube-scheduler.endpoints[2]" = "172.31.28.182",
//    "exporter-kube-state.apiGroup" = "monitoring.coreos.com",
//    "exporter-kube-state.enabled" = "true",
//    "exporter-kubelets.apiGroup" = "monitoring.coreos.com",
//    "exporter-kubelets.enabled" = "true",
//    "exporter-kubelets.https" = "true",
//    "exporter-kubernetes.apiGroup" = "monitoring.coreos.com",
//    "exporter-kubernetes.enabled" = "true",
//    "exporter-node.apiGroup" = "monitoring.coreos.com",
//    "exporter-node.enabled" = "true",
//    "exporter-node.ports.metrics.port" = "9796",
//    "exporter-node.resources.limits.cpu" = "200m",
//    "exporter-node.resources.limits.memory" = "200Mi",
//    "grafana.apiGroup" = "monitoring.coreos.com",
//    "grafana.enabled" = "true",
//    "grafana.persistence.enabled" = "false",
//    "grafana.persistence.size" = "10Gi",
//    "grafana.persistence.storageClass" = "default",
//    "grafana.serviceAccountName" = "cluster-monitoring",
//    "operator-init.enabled" = "true",
//    "operator.resources.limits.memory" = "500Mi",
//    "prometheus.additionalAlertManagerConfigs[0].static_configs[0].labels.cluster_id" = var.cluster_id,
//    "prometheus.additionalAlertManagerConfigs[0].static_configs[0].labels.cluster_name" = var.cluster_name,
//    "prometheus.additionalAlertManagerConfigs[0].static_configs[0].labels.level" = "cluster",
//    "prometheus.additionalAlertManagerConfigs[0].static_configs[0].targets[0]" = "alertmanager-operated.cattle-prometheus:9093",
//    "prometheus.apiGroup" = "monitoring.coreos.com",
//    "prometheus.enabled" = "true",
//    "prometheus.externalLabels.prometheus_from" = var.cluster_name,
//    "prometheus.persistence.enabled" = "false",
//    "prometheus.persistence.size" = "50Gi",
//    "prometheus.persistence.storageClass" = "default",
//    "prometheus.persistent.useReleaseName" = "true",
//    "prometheus.resources.core.limits.cpu" = "1000m",
//    "prometheus.resources.core.limits.memory" = "1000Mi",
//    "prometheus.resources.core.requests.cpu" = "750m",
//    "prometheus.resources.core.requests.memory" = "750Mi",
//    "prometheus.retention" = "12h",
//    "prometheus.ruleNamespaceSelector.matchExpressions[0].key" = "field.cattle.io/projectId",
//    "prometheus.ruleNamespaceSelector.matchExpressions[0].operator" = "In",
//    "prometheus.ruleNamespaceSelector.matchExpressions[0].values[0]" = local.rancher_system_project_id,
//    "prometheus.ruleSelector.matchExpressions[0].key" = "source",
//    "prometheus.ruleSelector.matchExpressions[0].operator" = "In",
//    "prometheus.ruleSelector.matchExpressions[0].values[0]" = "rancher-alert",
//    "prometheus.ruleSelector.matchExpressions[0].values[1]" = "rancher-monitoring",
//    "prometheus.secrets[0]" = "exporter-etcd-cert",
//    "prometheus.serviceAccountNameOverride" = "cluster-monitoring",
//    "prometheus.serviceMonitorNamespaceSelector.matchExpressions[0].key" = "field.cattle.io/projectId",
//    "prometheus.serviceMonitorNamespaceSelector.matchExpressions[0].operator" = "In",
//    "prometheus.serviceMonitorNamespaceSelector.matchExpressions[0].values[0]" = local.rancher_system_project_id
//  }
//  lifecycle {
//    ignore_changes = [
//      project_id
//    ]
//  }
//}
//
//resource "rancher2_app" "monitoring-operator" {
//  catalog_name     = "system-library"
//  name             = "monitoring-operator"
//  description      = "Rancher Cluster Monitoring"
//  project_id       = data.rancher2_project.system.id
//  template_name    = "rancher-monitoring"
//  template_version = "0.1.0"
//  target_namespace = rancher2_namespace.cattle-prometheus.name
//  answers = {
//    "apiGroup" = "monitoring.coreos.com",
//    "enabled" = "true",
//    "nameOverride" = "prometheus-operator",
//    "operator-init.enabled" = "true",
//    "operator.apiGroup" = "monitoring.coreos.com",
//    "operator.nameOverride" = "prometheus-operator",
//    "operator.resources.limits.memory" = "500Mi"
//  }
//  lifecycle {
//    ignore_changes = [
//      project_id
//    ]
//  }
//}

resource "rancher2_app" "istio-system" {
  catalog_name     = "system-library"
  name             = "cluster-istio"
  project_id       = data.rancher2_project.system.id
  template_name    = "rancher-istio"
  template_version = "1.4.700"
  target_namespace = rancher2_namespace.istio-system.name
  answers = {
    "certmanager.enabled" = "false",
    "enableCRDs" = "true",
    "galley.enabled" = "true",
    "gateways.enabled" = "false",
    "gateways.istio-ingressgateway.resources.limits.cpu" = "2000m",
    "gateways.istio-ingressgateway.resources.limits.memory" = "1024Mi",
    "gateways.istio-ingressgateway.resources.requests.cpu" = "100m",
    "gateways.istio-ingressgateway.resources.requests.memory" = "128Mi",
    "gateways.istio-ingressgateway.type" = "NodePort",
    "global.monitoring.type" = "cluster-monitoring",
    "global.rancher.clusterId" = var.cluster_id,
    "global.rancher.domain" = "demo-hosted.rancher.cloud",
    "istio_cni.enabled" = "false",
    "istiocoredns.enabled" = "false",
    "kiali.enabled" = "true",
    "mixer.enabled" = "true",
    "mixer.policy.enabled" = "true",
    "mixer.policy.resources.limits.cpu" = "4800m",
    "mixer.policy.resources.limits.memory" = "4096Mi",
    "mixer.policy.resources.requests.cpu" = "1000m",
    "mixer.policy.resources.requests.memory" = "1024Mi",
    "mixer.telemetry.resources.limits.cpu" = "4800m",
    "mixer.telemetry.resources.limits.memory" = "4096Mi",
    "mixer.telemetry.resources.requests.cpu" = "1000m",
    "mixer.telemetry.resources.requests.memory" = "1024Mi",
    "mtls.enabled" = "false",
    "nodeagent.enabled" = "false",
    "pilot.enabled" = "true",
    "pilot.resources.limits.cpu" = "1000m",
    "pilot.resources.limits.memory" = "4096Mi",
    "pilot.resources.requests.cpu" = "500m",
    "pilot.resources.requests.memory" = "2048Mi",
    "pilot.traceSampling" = "1",
    "security.enabled" = "true",
    "sidecarInjectorWebhook.enabled" = "true",
    "tracing.enabled" = "true",
    "tracing.jaeger.resources.limits.cpu" = "500m",
    "tracing.jaeger.resources.limits.memory" = "1024Mi",
    "tracing.jaeger.resources.requests.cpu" = "100m",
    "tracing.jaeger.resources.requests.memory" = "100Mi"
  }
  lifecycle {
    ignore_changes = [
      project_id
    ]
  }
}

resource "rancher2_project" "shop" {
  depends_on = [
    rancher2_cluster_sync.demo
  ]
  cluster_id = rancher2_cluster_sync.demo.id
  name       = "Shop"
}

resource "rancher2_namespace" "shop" {
  name       = "shop"
  project_id = rancher2_project.shop.id
}