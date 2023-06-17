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
    name = "tag:project"
    values = ["kandula"]
  }

}

data "aws_subnets" "private" {
  depends_on = [
    data.aws_vpc.kandula-vpc
  ]
  filter {
    name = "tag:tier"
    values = ["private"]
  }

  filter {
    name = "tag:project"
    values = ["kandula"]
  }

  # filter {
  #   name = "vpc-id"
  #   values = ["${data.aws_vpc.kandula-vpc.id}"]
  # }
}


