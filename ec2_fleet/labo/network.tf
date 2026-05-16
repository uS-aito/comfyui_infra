# VPCの作成
resource "aws_vpc" "example_vpc" {
  cidr_block           = "10.0.0.0/16" # VPCのCIDRブロックを設定します
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# パブリックサブネットの作成
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-northeast-1a"
}

resource "aws_eip" "example_eip" {
  count      = var.create_ec2 ? 1 : 0

  instance   = aws_instance.example_instance[0].id
  depends_on = [aws_internet_gateway.example_igw]
}

# パブリックサブネットのルートテーブル作成
resource "aws_route_table" "public_subnet_route" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_subnet_route.id
}

# インターネットゲートウェイの作成（Session Managerへの接続のために必要）
resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id
}

