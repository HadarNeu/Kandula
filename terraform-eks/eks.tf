module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.10.0"
  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids         = data.aws_subnets.private.ids
  cluster_endpoint_private_access = false 
  cluster_endpoint_public_access = true 
  
  enable_irsa = true
  
  tags = {
    Environment = "dev"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = data.aws_vpc.kandula-vpc.id

  eks_managed_node_group_defaults = {
      ami_type               = "AL2_x86_64"
      instance_types         = ["${var.group1_instance_type}"]
      vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  }

  eks_managed_node_groups = {
    
    group_1 = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
      instance_types = ["${var.group1_instance_type}"]
    }

    group_2 = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
      instance_types = ["${var.group2_instance_type}"]

    }
  }
}


resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = data.aws_vpc.kandula-vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

