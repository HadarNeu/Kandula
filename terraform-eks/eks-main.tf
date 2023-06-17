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
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "eks-cluster"
    "service" = "k8s"
  }

  vpc_id = data.aws_vpc.kandula-vpc.id

  eks_managed_node_group_defaults = {
      ami_type               = "AL2_x86_64"
      instance_types         = ["${var.group1_instance_type}"]
      vpc_security_group_ids = [aws_security_group.eks-worker-sg.id]
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


resource "aws_security_group" "eks-worker-sg" {
  name_prefix = "eks-worker-sg-kandula"
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

  tags = {
    "Name" = "eks-worker-sg-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "sg"
  }
}

######EKS Nodes Cluster SG############
resource "aws_security_group" "eks-worker-sg" {
  vpc_id = module.kandula-vpc.vpc_id
  name   = "eks-worker-sg-${var.project_name}"

  tags = {
    "Name" = "eks-worker-sg-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "sg"
  }
}

resource "aws_security_group_rule" "eks_ssh_access" {
  description       = "allow ssh access from the cidr block"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.eks-worker-sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
}

resource "aws_security_group_rule" "eks_consul_dns_access" {
  description       = "allow comsul dns access from anywhere"
  from_port         = 8600
  protocol          = "tcp"
  security_group_id = aws_security_group.eks-worker-sg.id
  to_port           = 8600
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "eks_consul_rcp_access" {
  description       = "allow rcp access from anywhere- allow requests from agents"
  from_port         = 8300
  protocol          = "tcp"
  security_group_id = aws_security_group.eks-worker-sg.id
  to_port           = 8300
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "eks_consul_serf_lan_access" {
  description       = "allow serf LAN access from anywhere- used to handle gossip"
  from_port         = 8301
  protocol          = "tcp"
  security_group_id = aws_security_group.eks-worker-sg.id
  to_port           = 8301
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "eks_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks-worker-sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}



