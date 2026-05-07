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

# SSMを使うためのプロファイル
resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.example_role.name
}