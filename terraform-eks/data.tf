data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = ["Kandula-VPC"]
  }

  filter {
    name = "tag:Project"
    values = ["Kandula"]
  }

}

data "aws_subnets" "private" {
  filter {
    name = "tag:Tier"
    values = ["Private"]
  }

  filter {
    name = "vpc-id"
    values = data.vpc.vpc_id
  }
}


