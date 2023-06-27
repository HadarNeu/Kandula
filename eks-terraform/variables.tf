########REQUIRED########
######Make sure cluster name is updated with VPC!###########
#######Creation of cluster name EKS##########

locals {
  # cluster_name = "eks-${random_string.suffix.result}-kandula"
  cluster_name = "eks-cluster-kandula"
  k8s_service_account_namespace = "default"
  k8s_service_account_name = "sa-kandula"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}


# locals {
#   k8s_service_account_namespace = "default"
#   k8s_service_account_name      = "opsschool-sa"
#   cluster_name = "opsschool-eks-hadar-YrIrJOah"
# }

variable "vpc-name" {
  description = "The name of the VPC"
  default     = "vpc-kandula"
  type        = string
}

variable "aws_region" {
  default = "us-west-2"
  type    = string
}

variable "project_name" {
  description = "The key name of the project"
  default     = "kandula"
  type        = string
}

variable "kubernetes_version" {
  default = 1.24
  description = "kubernetes version"
}


variable "aws_profile" {
  description = "The profile of the credentials"
  default     = null
  type        = string
}

variable "group1_instance_type" {
  description = "The type of the ec2"
  default     = "t3.medium"
  type        = string
}

variable "group2_instance_type" {
  description = "The type of the ec2"
  default     = "t3.medium"
  type        = string
}

variable "key_name" {
  description = "The key name of the Key Pair to use for the instance"
  default     = "jenkins-kandula"
  type        = string
}

variable "rds-identifier" {
  description = "The name of the db instance"
  default     = "rds-postgres-kandula"
  type        = string
}


