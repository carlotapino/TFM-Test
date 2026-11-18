provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAIxcvODNsdf8soi87s56r)"
  secret_key = "WD97W9JWF09JS0/&98dfpw$)PFOUIG9(J0)"
}

resource "aws_security_group" "test" {
  name        = "test"
  description = "Test security group"
  #vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

}

resource "aws_s3_bucket" "bucket" {
  bucket = "bucket-prova"
}
