variable "region" {
  default = "us-east-1"
}

variable "aws_profile" {
  type        = string
  description = "AWSのプロファイル名"
  default     = "terraform-eks"
}

variable "project" {
  default = "eks"
}

variable "environment" {
  default = "dev"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "num_subnets" {
  default = 3
}

variable "key_name" {
  type    = "string"
  default = "ambitious_key"
}

locals {
  base_tags = {
    Project     = var.project
    Terraform   = "true"
    Environment = var.environment
  }

  default_tags    = merge(local.base_tags, map("kubernetes.io/cluster/${local.cluster_name}", "shared"))
  base_name       = "${var.project}-${var.environment}"
  cluster_name    = "${local.base_name}-amb-cluster"
  cluster_version = "1.18"

  public_key_file  = "./${var.key_name}.id_rsa.pub"
  private_key_file = "./${var.key_name}.id_rsa"
}
