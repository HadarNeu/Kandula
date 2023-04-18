data "aws_availability_zones" "available" {}

#This is used to get the user's account number
data "aws_caller_identity" "current" {}

data "aws_ami" "ubuntu-ami" {
  most_recent = true
  owners      = [var.ubuntu_account_number]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-${var.ubuntu_version}-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#####Pre-Configured Jenkins AMI############
data "aws_ami" "jenkins-server-ami" {
  most_recent = true
  owners      = [data.aws_caller_identity.current.account_id]

  filter {
    name   = "name"
    values = [var.jenkins-ami-name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


###Data resource for existing hosted zone###
data "aws_route53_zone" "hosted-zone-hadar" {
  name         = "hadar.infitest.net"
  private_zone = false
}

