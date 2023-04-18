data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

data "aws_vpc" "kandula-vpc" {
  filter {
    name = "tag:Name"
    values = ["${var.vpc-name}"]
  }

  filter {
    name = "tag:Project"
    values = ["Kandula"]
  }

}

data "aws_subnets" "private" {
  depends_on = [
    data.aws_vpc.kandula-vpc
  ]
  filter {
    name = "tag:Tier"
    values = ["Private"]
  }

  filter {
    name = "vpc-id"
    values = ["${data.aws_vpc.kandula-vpc.id}"]
  }
}


