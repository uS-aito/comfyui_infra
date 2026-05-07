terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-20260505"
    key    = "comfyui_infra/ecr/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
