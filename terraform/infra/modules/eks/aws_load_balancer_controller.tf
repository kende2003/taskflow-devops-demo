resource "aws_iam_role" "alb_controller" {
  name = "eks-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

resource "aws_iam_policy" "alb_controller" {
  name        = "AmazonEKSLoadBalancerControllerPolicy"
  description = "Policy for AWS Load Balancer Controller"

  policy = file("${path.module}/iam-policy-alb-controller.json")
}

resource "aws_iam_role_policy_attachment" "alb_controller_policy" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

resource "aws_eks_pod_identity_association" "alb_controller" {
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "alb-controller-sa"
  role_arn        = aws_iam_role.alb_controller.arn
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.8.1"

 set = [
    { name = "clusterName", value = aws_eks_cluster.this.name },
    { name = "region", value = var.aws_region },
    { name = "vpcId", value = var.vpc_id },
    { name = "serviceAccount.create", value = "true" },
    { name = "serviceAccount.name", value = "alb-controller-sa" },
    { name = "serviceAccount.roleArn", value = aws_iam_role.alb_controller.arn }
  ]

  depends_on = [aws_iam_role_policy_attachment.alb_controller_policy]
}
