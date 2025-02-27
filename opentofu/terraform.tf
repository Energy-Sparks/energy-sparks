terraform {
  backend "s3" {
    bucket  = "es-opentofu-state"
    key     = "opentofu.tfstate"
    encrypt = true
  }
}
