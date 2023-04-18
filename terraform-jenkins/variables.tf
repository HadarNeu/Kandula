variable "aws_region" {
  default = "us-west-2"
  type    = string
}

variable "instance_type" {
  description = "The type of the ec2"
  default     = "t2.micro"
  type        = string
}

variable "key_name" {
  description = "The key name of the Key Pair to use for the instance"
  default     = "jenkins-kandula"
  type        = string
}


variable "jenkins_servers_instances_count" {
  description = "The number of Nginx instances to create"
  default     = 1
}

variable "volumes_type" {
  description = "The type of all the disk instances in my project"
  default     = "gp3"
}

variable "owner_tag" {
  description = "The owner tag will be applied to every resource in the project through the 'default variables' feature"
  default     = "Ops-School"
  type        = string
}
