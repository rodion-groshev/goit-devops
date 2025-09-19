resource "helm_release" "argo_cd" {
  timeout = 900
  atomic  = true
  wait    = true
  name       = var.name
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  create_namespace = true
  
values = [
  yamlencode({
    installCRDs = true
    dex = { enabled = false }
  })
]


}