variable create_ec2 {
  type    = bool
  default = true
}

variable "root_volume_size" {
  type    = number
  # default = 80
  default = 120
}