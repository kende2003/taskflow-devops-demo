data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket = "taskflow-tf-state-bucket"
    key    = "infra/terraform.tfstate"
    region = "eu-central-1"
  }
}

locals {
  eks_cluster_name  = data.terraform_remote_state.infra.outputs.eks_cluster_name
}

data "aws_eks_cluster" "eks" {
  name = local.eks_cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = local.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}
