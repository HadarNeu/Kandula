
resource "aws_instance" "jenkins_server" {
  count= var.jenkins_instances_count
  ami = data.jenkins-server-ami.id
  instance_type = var.jenkins-instance-type
  key_name = var.key_name
  subnet_id                   = module.kandula-vpc.private_subnets_id[count.index]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-servers-sg.id]
  user_data            = file("${path.module}/scripts/consul-agent-jenkins.sh")
  iam_instance_profile   = aws_iam_instance_profile.jenkins-server.name

  tags = {
    Name = "Jenkins Server"
    consul_server = "true"
  }

}
