module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  region       = var.region
}

/*module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
}*/

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
  aws_iam_user      = var.aws_iam_user
  configure_kubectl = true
}


module "auth_db" {
  source            = "./modules/auth_db"
  eks_node_role_arn = module.eks.eks_node_role_arn
  db_password       = var.auth_db_password
  db_user           = var.auth_db_user
  db_name           = var.auth_db_name
  db_storage        = var.auth_db_storage
  aws_iam_user      = var.aws_iam_user

  depends_on = [module.eks]
}

module "auth_api" {
  source         = "./modules/auth_api"
  db_name        = module.auth_db.auth_db_name
  db_user        = module.auth_db.auth_db_user
  db_password    = module.auth_db.auth_db_password
  db_host        = module.auth_db.auth_db_host
  auth_api_image_tag = var.auth_api_image_tag

  depends_on = [module.auth_db]
}


