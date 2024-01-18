moved {
  from = helm_release.this
  to   = helm_release.controller
}

moved {
  from = kubernetes_manifest.this
  to   = kubernetes_manifest.controller
}
