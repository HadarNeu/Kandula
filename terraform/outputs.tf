

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_name" {
  description = "EKS Cluster Name ***IMPORTANT****"
  value       = local.cluster_name
}

output "vpc-name" {
  description = "The name of the VPC "
  value       = module.kandula-vpc.vpc_name
}

output "private-subnets" {
  description = "The id of the private subnets"
  value       = module.kandula-vpc.*.private_subnets_id
}

output "servers_subnet1" {
  description = "The ip of consul instances"
  value = aws_instance.consul_server_subnet1.*.private_ip
}

output "servers_subnet2" {
  description = "The ip of consul instances"
  value = aws_instance.consul_server_subnet2.*.private_ip
}

output "bastion_public_ip" {
  description = "The ip of bastion server"
  value = aws_instance.bastion.*.public_ip
}

output "consul_alb_dns" {
  description = "The DNS of the consul load balancer we created"
  value = aws_lb.consul_alb.dns_name
}

output "jenkins_alb_dns" {
  description = "The DNS of the consul load balancer we created"
  value = aws_lb.jenkins_alb.dns_name
}

output "jenkins-ui-url" {
  description = "The A record used for jenkins UI"
  value = var.jenkins-ui-url
}

output "jenkins-sg" {
  description = "The sg of jenkins-for cloud configuration"
  value = aws_security_group.jenkins-servers-sg.id
}

