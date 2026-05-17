data "aws_ssm_parameter" "mlami" {
  name = "/aws/service/deeplearning/ami/x86_64/base-oss-nvidia-driver-gpu-amazon-linux-2023/latest/ami-id"
}

# EC2インスタンスの作成
resource "aws_instance" "example_instance" {
  count         = var.create_ec2 ? 1 : 0

  ami           = data.aws_ssm_parameter.mlami.value # EC2インスタンスのAMI IDをSSMパラメータから取得します
  instance_type = "g4dn.xlarge"              # インスタンスタイプを設定します
  subnet_id     = aws_subnet.public_subnet.id

  # Systems Managerとsecret managerにアクセスするためのロール
  iam_instance_profile = aws_iam_instance_profile.test_profile.name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  # docker install
  user_data = <<-EOF
              #!/bin/bash
              # cloudinit start time
              date
              # install and setup docker
              # ref: https://qiita.com/myaX/items/fdbf0dd55675f306d676
              dnf -y update
              dnf -y install docker
              systemctl start docker
              systemctl enable docker
              # init instance store
              # ref: https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/making-instance-stores-available-on-your-instances.html
              mkfs -t xfs /dev/nvme1n1
              mkdir /models
              mount /dev/nvme1n1 /models
              # make models directory
              mkdir /models/loras
              mkdir /models/StableDiffusion
              mkdir /models/Ultralytics
              mkdir /models/docker
              mkdir /models/RealESRGAN
              # install s5cmd
              curl -L -o /tmp/s5cmd_2.3.0_Linux-64bit.tar.gz https://github.com/peak/s5cmd/releases/download/v2.3.0/s5cmd_2.3.0_Linux-64bit.tar.gz
              tar -xzf /tmp/s5cmd_2.3.0_Linux-64bit.tar.gz
              chmod +x s5cmd
              mv s5cmd /usr/local/bin/
              # download models from s3
              s5cmd cp 's3://comfyui-models-${data.aws_caller_identity.current.account_id}/StableDiffusion/*' /models/StableDiffusion/
              s5cmd cp 's3://comfyui-models-${data.aws_caller_identity.current.account_id}/Ultralytics/*' /models/Ultralytics/
              s5cmd cp 's3://comfyui-models-${data.aws_caller_identity.current.account_id}/lora/*' /models/loras/
              s5cmd cp 's3://comfyui-models-${data.aws_caller_identity.current.account_id}/RealESRGAN/*' /models/RealESRGAN/
              # download comfyui custom image from S3
              s5cmd cp 's3://comfyui-models-${data.aws_caller_identity.current.account_id}/docker/comfyui.tar.gz' /models/docker/comfyui.tar.gz
              docker load -i /models/docker/comfyui.tar.gz
              # install and start comfyui image
              docker run -d --gpus all -p 8188:8188 \
                -v /models/loras:/app/ComfyUI/models/loras \
                -v /models/StableDiffusion:/app/ComfyUI/models/checkpoints \
                -v /models/Ultralytics:/app/ComfyUI/models/ultralytics \
                -v /models/RealESRGAN:/app/ComfyUI/models/upscale_models \
                --name comfyui ghcr.io/us-aito/comfyui_infra/comfyui:latest
              # cloudinit end time
              date
              EOF
}
