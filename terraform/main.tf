terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4"
    }
  }

  cloud {
    organization = "mvot-org"

    workspaces {
      name = "microservice-app"
    }
  }
}

provider "aws" {
  region     = "us-west-1"
}

resource "aws_key_pair" "rsa_key" {
  key_name   = "rsa_key"
  public_key = var.public_ssh_key
}