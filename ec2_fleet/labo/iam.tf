# EC2インスタンスに付与するためのロール
resource "aws_iam_role" "example_role" {
  name = "example-role"

  # このロールにアタッチするポリシー（権限）を設定します
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

# SSMを使うためのポリシーをアタッチする
resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.example_role.name
}

# SQSからデータを読み出すためのポリシー
resource "aws_iam_role_policy" "sqs_read_policy" {
  name = "sqs-read-policy"
  role = aws_iam_role.example_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility",
        ]
        Resource = [
          aws_sqs_queue.labo_queue.arn,
          aws_sqs_queue.labo_dlq.arn,
        ]
      }
    ]
  })
}

# S3バケットからモデルをダウンロードするためのポリシー
resource "aws_iam_role_policy" "s3_model_read_policy" {
  name = "s3-model-read-policy"
  role = aws_iam_role.example_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
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

# S3バケットに出力ファイルをアップロードするためのポリシー
resource "aws_iam_role_policy" "s3_output_write_policy" {
  name = "s3-output-write-policy"
  role = aws_iam_role.example_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::output-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::output-${data.aws_caller_identity.current.account_id}/*",
        ]
      }
    ]
  })
}

# SSMを使うためのプロファイル
resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.example_role.name
}