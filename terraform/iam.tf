########Consul Servers##########

# Create an IAM role for the auto-join
resource "aws_iam_role" "consul-join" {
  name               = "role-consul-join-kandula"
  assume_role_policy = file("${path.module}/policies/assume-role.json")
  tags = {
    "Name" = "role-consul-join-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "role"
  }
  
}

# Create the policy
resource "aws_iam_policy" "consul-join" {
  name        = "policy-consul-join-kandula"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = file("${path.module}/policies/describe-instances.json")
  tags = {
    "Name" = "policy-consul-join-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "policy"
  }
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul-join-att-consul" {
  name       = "consul-join-kandula"
  roles      = [aws_iam_role.consul-join.name]
  policy_arn = aws_iam_policy.consul-join.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul-join" {
  name  = "profile-consul-join-kandula"
  role = aws_iam_role.consul-join.name
}

########Jenkins Servers##########

# Create an IAM role for the jenkins server
resource "aws_iam_role" "jenkins-role" {
  name               = "role-jenkins-kandula"
  assume_role_policy = file("${path.module}/policies/assume-role.json")
  tags = {
    "Name" = "role-jenkins-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "role"
  }
}

# Create the instance profile
resource "aws_iam_instance_profile" "jenkins-server" {
  name  = "profile-jenkins-kandula"
  role = aws_iam_role.jenkins-role.name
}

# Create the policy
resource "aws_iam_policy" "ec2-full-access" {
  name        = "policy-ec2-full-access-kandula"
  description = "Allows servers to control ec2"
  policy      = file("${path.module}/policies/ec2-full-access.json")
  tags = {
    "Name" = "policy-ec2-full-access-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "policy"
  }
}

# Attach the ec2 policy to jenkins
resource "aws_iam_policy_attachment" "ec2-full-att-jenkins" {
  name       = "ec2-full-access-att-jenkins-kandula"
  roles      = [aws_iam_role.jenkins-role.name]
  policy_arn = aws_iam_policy.ec2-full-access.arn
}


########Eks##########

# Create the policy
resource "aws_iam_policy" "eks-node" {
  name        = "eks-node-access-kandula"
  description = "Allows eks permissions"
  policy      = file("${path.module}/policies/eks-node-policy.json")
  tags = {
    "Name" = "policy-eks-node-access-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "policy"
  }
}

# Attach the policy
resource "aws_iam_policy_attachment" "eks-node" {
  name       = "eks-node-access-kandula"
  roles      = [aws_iam_role.jenkins-role.name]
  policy_arn = aws_iam_policy.eks-node.arn
}


########Ansible ##########

# Create an IAM role for the ansible server
resource "aws_iam_role" "ansible-role" {
  name               = "role-ansible-kandula"
  assume_role_policy = file("${path.module}/policies/assume-role.json")
  tags = {
    "Name" = "role-ansible-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "role"
  }
}

# Create the instance profile
resource "aws_iam_instance_profile" "ansible-server" {
  name  = "profile-ansible-kandula"
  role = aws_iam_role.ansible-role.name
}

# Attach the ec2 policy to ansible
resource "aws_iam_policy_attachment" "ec2-full-att-ansible" {
  name       = "ec2-full-access-att-ansible-kandula"
  roles      = [aws_iam_role.ansible-role.name]
  policy_arn = aws_iam_policy.ec2-full-access.arn
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul-join-att-ansible" {
  name       = "consul-join-att-ansible-kandula"
  roles      = [aws_iam_role.ansible-role.name]
  policy_arn = aws_iam_policy.consul-join.arn
}




