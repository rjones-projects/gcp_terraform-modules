config {
  # TFLint recursive runs from repo root cannot resolve the local
  # "finops_labels" module path used only for label policy evaluation.
  # Ignore this module to avoid "module is not found" errors here.
  # Finops module ist tested separatly 
  ignore_module = {
    finops_labels = true
  }
}

