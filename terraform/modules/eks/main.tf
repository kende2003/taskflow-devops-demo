
resource "aws_eks_cluster" "this" {
  name = "${var.project_name}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

    version = "1.33"

    bootstrap_self_managed_addons = true

    vpc_config {
      subnet_ids = var.subnet_ids
      security_group_ids = [aws_security_group.eks_cluster.id]
    }

    encryption_config {
      provider {
        key_arn = aws_kms_key.eks.arn
      }
      resources = ["secrets"]
    }

    access_config {
       authentication_mode = "API"
        bootstrap_cluster_creator_admin_permissions = true
    }

    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

    depends_on = [ 
        aws_iam_role.eks_cluster,
        aws_kms_key.eks
     ]
}

resource "aws_eks_node_group" "taskflow_nodes" {
  cluster_name = aws_eks_cluster.this.name
  node_group_name = "eks-worker-nodes"
  node_role_arn = aws_iam_role.eks_node.arn
  subnet_ids = var.subnet_ids
  instance_types = ["t3.xlarge"]
  
  remote_access {
    ec2_ssh_key = "kencs-eks-key"
    source_security_group_ids = [aws_security_group.bastion.id]
  }

scaling_config {
  desired_size = 1
  max_size = 4
  min_size = 1
}

update_config {
  max_unavailable = 1
}

lifecycle {
  ignore_changes = [ 
    scaling_config[0].desired_size,
    scaling_config[0].max_size,
    scaling_config[0].min_size
   ]
}

labels = {
  "node-type" = "taskflow_worker_nodes"
}

tags = {
    Name = "taskflow_worker_nodes"
}

depends_on = [
    aws_iam_role_policy_attachment.eks_worker_policy,
    aws_iam_role_policy_attachment.ecr_read_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_kms_key.eks
  ]
}

resource "terraform_data" "configure_kubectl" {
 count = var.configure_kubectl ? 1 : 0
 depends_on = [ aws_eks_cluster.this ] 

 provisioner "local-exec" {
    command = "aws eks --region ${var.aws_region} update-kubeconfig --name ${aws_eks_cluster.this.name} --alias ${var.project_name}-eks-cluster"
   
 }
}