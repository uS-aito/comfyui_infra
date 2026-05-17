# github actionsからアクセスするためのロール
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowGitHubActionsToAssumeRole",
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:uS-aito/comfyui_infra:*"
                }
            }
        }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "github_actions_policy" {
  name = "github-actions-policy"
  role = aws_iam_role.github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:ListBucket",
        ]
        Resource = [
          "arn:aws:s3:::comfyui-models-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::comfyui-models-${data.aws_caller_identity.current.account_id}/*",
        ]
      }
    ]
  })
}
