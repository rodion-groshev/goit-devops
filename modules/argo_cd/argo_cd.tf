resource "helm_release" "argo_cd" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  create_namespace = true
  wait             = true
  atomic           = false # let it fail without uninstalling so you can inspect
  timeout          = 1200  # first install often needs longer
  # wait_for_jobs  = true           # enable if chart runs Jobs you must wait for

  values = [
    yamlencode({
      installCRDs = true
      dex         = { enabled = false }
    })
  ]
}
