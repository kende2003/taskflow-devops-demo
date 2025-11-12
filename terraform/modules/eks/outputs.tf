
output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_auth_token" {
  value = data.aws_eks_cluster_auth.this.token
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node.arn
}

