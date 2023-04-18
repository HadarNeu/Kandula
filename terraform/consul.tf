resource "aws_instance" "consul_server_subnet1" {
  depends_on = [
    aws_iam_instance_profile.consul-join,
    aws_security_group.opsschool_consul
  ]
  count = var.counsul_servers_count_subnet1
  ami           = data.aws_ami.ubuntu-ami.id
  instance_type = var.consul_instance_type
  key_name      = var.key_name
  subnet_id                   = module.kandula-vpc.private_subnets_id[0]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name

  vpc_security_group_ids = [aws_security_group.opsschool_consul.id]
  user_data            = file("${path.module}/scripts/consul-server-user-data.sh")

  tags = {
    Name = "consul-server-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${module.kandula-vpc.vpc_name}"
    consul_server = "true"
  }

}

resource "aws_instance" "consul_server_subnet2" {
  depends_on = [
    aws_iam_instance_profile.consul-join,
    aws_security_group.opsschool_consul
  ]
  count = var.counsul_servers_count_subnet2
  ami           = data.aws_ami.ubuntu-ami.id
  instance_type = var.consul_instance_type
  key_name      = var.key_name
  subnet_id                   = module.kandula-vpc.private_subnets_id[1]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name

  vpc_security_group_ids = [aws_security_group.opsschool_consul.id]
  user_data            = file("${path.module}/scripts/consul-server-user-data.sh")

  tags = {
    Name = "consul-server-${regex(".$", data.aws_availability_zones.available.names[count.index])}-${module.kandula-vpc.vpc_name}"
    consul_server = "true"
  }
}
