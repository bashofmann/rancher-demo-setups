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

resource "rancher2_namespace" "istio-system" {
  name       = "istio-system"
  project_id = data.rancher2_project.system.id
}

resource "rancher2_app" "istio" {
  catalog_name     = "system-library"
  name             = "cluster-istio"
  project_id       = rancher2_namespace.istio-system.project_id
  template_name    = "rancher-istio"
  template_version = "1.4.1000"
  target_namespace = rancher2_namespace.istio-system.name
  answers = {
    "certmanager.enabled"                                     = false
    "enableCRDs"                                              = true
    "galley.enabled"                                          = true
    "gateways.enabled"                                        = false
    "gateways.istio-ingressgateway.resources.limits.cpu"      = "2000m"
    "gateways.istio-ingressgateway.resources.limits.memory"   = "1024Mi"
    "gateways.istio-ingressgateway.resources.requests.cpu"    = "100m"
    "gateways.istio-ingressgateway.resources.requests.memory" = "128Mi"
    "gateways.istio-ingressgateway.type"                      = "NodePort"
    "global.monitoring.type"                                  = "cluster-monitoring"
    "global.rancher.clusterId"                                = rancher2_cluster_sync.demo.cluster_id
    "istio_cni.enabled"                                       = "false"
    "istiocoredns.enabled"                                    = "false"
    "kiali.enabled"                                           = "true"
    "mixer.enabled"                                           = "true"
    "mixer.policy.enabled"                                    = "true"
    "mixer.policy.resources.limits.cpu"                       = "4800m"
    "mixer.policy.resources.limits.memory"                    = "4096Mi"
    "mixer.policy.resources.requests.cpu"                     = "1000m"
    "mixer.policy.resources.requests.memory"                  = "1024Mi"
    "mixer.telemetry.resources.limits.cpu"                    = "4800m",
    "mixer.telemetry.resources.limits.memory"                 = "4096Mi"
    "mixer.telemetry.resources.requests.cpu"                  = "1000m"
    "mixer.telemetry.resources.requests.memory"               = "1024Mi"
    "mtls.enabled"                                            = false
    "nodeagent.enabled"                                       = false
    "pilot.enabled"                                           = true
    "pilot.resources.limits.cpu"                              = "1000m"
    "pilot.resources.limits.memory"                           = "4096Mi"
    "pilot.resources.requests.cpu"                            = "500m"
    "pilot.resources.requests.memory"                         = "2048Mi"
    "pilot.traceSampling"                                     = "1"
    "security.enabled"                                        = true
    "sidecarInjectorWebhook.enabled"                          = true
    "tracing.enabled"                                         = true
    "tracing.jaeger.resources.limits.cpu"                     = "500m"
    "tracing.jaeger.resources.limits.memory"                  = "1024Mi"
    "tracing.jaeger.resources.requests.cpu"                   = "100m"
    "tracing.jaeger.resources.requests.memory"                = "100Mi"
  }

  lifecycle {
    ignore_changes = [
      project_id
    ]
  }
}

resource "rancher2_app" "longhorn" {
  catalog_name     = "library"
  name             = "longhorn"
  project_id       = rancher2_namespace.longhorn-system.project_id
  template_name    = "longhorn"
  template_version = "1.0.2"
  target_namespace = rancher2_namespace.longhorn-system.name
  answers = {

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