########Consul Servers##########

# Create an IAM role for the auto-join
resource "aws_iam_role" "consul-join" {
  name               = "opsschool-consul-join"
  assume_role_policy = file("${path.module}/policies/assume-role.json")
}

# Create the policy
resource "aws_iam_policy" "consul-join" {
  name        = "opsschool-consul-join"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = file("${path.module}/policies/describe-instances.json")
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul-join" {
  name       = "opsschool-consul-join"
  roles      = [aws_iam_role.consul-join.name]
  policy_arn = aws_iam_policy.consul-join.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul-join" {
  name  = "opsschool-consul-join"
  role = aws_iam_role.consul-join.name
}

########Jenkins Servers##########

# Create an IAM role for the jenkins server
resource "aws_iam_role" "jenkins-role" {
  name               = "jenkins-server-role-kandula"
  assume_role_policy = file("${path.module}/policies/assume-role.json")
}

# Create the instance profile
resource "aws_iam_instance_profile" "jenkins-server" {
  name  = "jenkins-server-profile"
  role = aws_iam_role.jenkins-role.name
}

# Create the policy
resource "aws_iam_policy" "ec2-full-access" {
  name        = "ec2-full-access-jenkins"
  description = "Allows jenkins servers to control ec2"
  policy      = file("${path.module}/policies/ec2-full-access.json")
}

# Attach the policy
resource "aws_iam_policy_attachment" "ec2-full-access" {
  name       = "ec2-full-access-jenkins"
  roles      = [aws_iam_role.jenkins-role.name]
  policy_arn = aws_iam_policy.ec2-full-access.arn
}

# Create the policy
resource "aws_iam_policy" "eks-node" {
  name        = "eks-node-access"
  description = "Allows eks permissions"
  policy      = file("${path.module}/policies/eks-node-policy.json")
}

# Attach the policy
resource "aws_iam_policy_attachment" "eks-node" {
  name       = "eks-node-access-jenkins"
  roles      = [aws_iam_role.jenkins-role.name]
  policy_arn = aws_iam_policy.eks-node.arn
}
