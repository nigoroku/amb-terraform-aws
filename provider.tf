provider "aws" {
  version = "3.0"
  region  = var.region
  profile = var.aws_profile
}
provider "local" {
  version = "2.0.0"
}
provider "tls" {
  version = "3.0.0"
}
