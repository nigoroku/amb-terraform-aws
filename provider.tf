provider "aws" {
  version    = ">= 2.7"
  region     = var.region
  access_key = var.secret_access_key
  secret_key = var.secret_key
}
