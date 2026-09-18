terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Pronto para receber a configuracao remota via -backend-config.
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Disciplina = "EDA"
      ManagedBy  = "terraform"
    }
  }
}

module "lake" {
  source = "./modules/lake"

  sufixo     = var.sufixo
  teto_bytes = var.teto_bytes
}
