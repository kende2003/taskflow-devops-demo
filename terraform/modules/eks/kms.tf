resource "aws_kms_key" "eks" {
  description             = "KMS key for EKS secrets encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {
        Sid: "AllowRootFullAccess",
        Effect: "Allow",
        Principal: {
          AWS: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action: "kms:*",
        Resource: "*"
      },

      {
        Sid: "AllowKendiFullManagement",
        Effect: "Allow",
        Principal: {
          AWS: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/kendi006@gmail.com"
        },
        Action: [
          "kms:*"
        ],
        Resource: "*"
      },

      {
        Sid: "AllowEksClusterUseKey",
        Effect: "Allow",
        Principal: {
          AWS: aws_iam_role.eks_cluster.arn
        },
        Action: [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource: "*"
      }
    ]
  })
}
