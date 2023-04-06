data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu-ami" {
  most_recent = true
  owners      = [var.ubuntu_account_number]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-${var.ubuntu_version}-amd64-server-*"]
  }
}