terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-20260505"
    key    = "comfyui_infra/s3/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
