resource "aws_iam_role" "instance_role" {
  name = "${var.project}-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_policy" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
resource "aws_iam_role_policy" "custom_access" {
  role = aws_iam_role.instance_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = "sqs:*", Resource = "*" },
      { Effect = "Allow", Action = "s3:*", Resource = "*" }
    ]
  })
}
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.project}-instance-profile"
  role = aws_iam_role.instance_role.name
}