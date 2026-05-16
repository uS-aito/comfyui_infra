# Dead Letter Queue
resource "aws_sqs_queue" "labo_dlq" {
  name                      = "labo-dlq"
  message_retention_seconds = 1209600 # 14日間
}

# メインキュー
resource "aws_sqs_queue" "labo_queue" {
  name                       = "labo-queue"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 86400 # 1日間
  receive_wait_time_seconds  = 20    # ロングポーリング

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.labo_dlq.arn
    maxReceiveCount     = 3
  })
}

output "sqs_queue_url" {
  value = aws_sqs_queue.labo_queue.url
}

output "sqs_queue_arn" {
  value = aws_sqs_queue.labo_queue.arn
}
