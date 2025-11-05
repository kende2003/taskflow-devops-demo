module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  region       = var.region
}

module "rds" {
  source = "./modules/rds"

  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  subnet_ids     = module.vpc.private_db_subnet_ids
  tag_name       = var.project_name
  password       = var.password

}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
}

module "eks" {
  source = "./modules/eks"

  vpc_id = module.vpc.vpc_id

  subnet_ids = [
    module.vpc.private_a_subnet_id,
    module.vpc.private_b_subnet_id
  ]

  project_name      = var.project_name
  aws_region        = var.region
  aws_cli_profile   = var.profile
  configure_kubectl = true
}