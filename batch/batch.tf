resource "aws_batch_compute_environment" "spot" {
  name = "${var.project}-spot-env"
  type                     = "MANAGED"
  compute_resources {
    type                = "SPOT"
    max_vcpus           = 16
    min_vcpus           = 0
    instance_role       = aws_iam_instance_profile.instance_profile.arn
    instance_type       = ["g4dn.xlarge"]
    subnets            = [aws_subnet.public.id]
    security_group_ids = [aws_security_group.batch_sg.id]
    allocation_strategy = "SPOT_CAPACITY_OPTIMIZED"
  }
  # 修正点: Service Roleの作成は省略(AWS管理ロールを想定)
  service_role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/batch.amazonaws.com/AWSServiceRoleForBatch"
}

resource "aws_batch_job_queue" "queue" {
  name     = "${var.project}-job-queue"
  priority = 1
  state    = "ENABLED"
  
  compute_environment_order {
    order = 1
    compute_environment = aws_batch_compute_environment.spot.arn
  }
}

resource "aws_batch_job_definition" "comfyui" {
  name = "${var.project}-job-def"
  type = "container"
  container_properties = jsonencode({
    # image = "<YOUR_ACCOUNT_ID>.dkr.ecr.ap-northeast-1.amazonaws.com/comfyui-worker:latest"
    image = "nginx:latest"
    resourceRequirements = [
      { type = "VCPU", value = "2" },
      { type = "MEMORY", value = "8192" },
      { type = "GPU", value = "1" }
    ]
    environment = [
      { name = "SQS_QUEUE_URL", value = aws_sqs_queue.main.id },
      { name = "S3_BUCKET_NAME", value = "YOUR-IMAGE-BUCKET-NAME" }
    ]
    linuxParameters = {
      devices = [{ hostPath = "/dev/nvidia0", containerPath = "/dev/nvidia0", permissions = ["read", "write", "mknod"] }]
    }
  })
}