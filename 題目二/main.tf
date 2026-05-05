# AWS Provider
provider "aws" {
  region = "ap-northeast-1"
}

# VPC module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "asiayo-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-1a", "ap-northeast-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
  }
}

# EKS Module
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "asiayo-cluster"
  cluster_version = "1.29"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_types = ["t3.medium"]
    }
  }
}