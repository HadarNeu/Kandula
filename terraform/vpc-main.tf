module "kandula-vpc" {
    source = "./vpc-module"
    # cluster_name = local.cluster_name
    vpc_name = "vpc-kandula"
    project_name = var.project_name
}