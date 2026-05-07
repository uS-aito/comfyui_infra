data "aws_ssm_parameter" "mlami" {
  name = "/aws/service/deeplearning/ami/x86_64/base-oss-nvidia-driver-gpu-amazon-linux-2023/latest/ami-id"
}

# EC2インスタンスの作成
resource "aws_instance" "example_instance" {
  ami           = data.aws_ssm_parameter.mlami.value # EC2インスタンスのAMI IDをSSMパラメータから取得します
  instance_type = "g4dn.xlarge"              # インスタンスタイプを設定します
  subnet_id     = aws_subnet.public_subnet.id

  # Systems Managerとsecret managerにアクセスするためのロール
  iam_instance_profile = aws_iam_instance_profile.test_profile.name

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
              # install and start comfyui image
              mkdir /models/loras
              docker run -d --gpus all -p 8188:8188 -v /models/loras:/app/ComfyUI/models/loras --name comfyui ghcr.io/us-aito/comfyui_infra/comfyui:latest
              # cloudinit end time
              date
              EOF
}
