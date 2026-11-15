provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAIOSFODNN7EXAMPLE"
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
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_s3_bucket" "bucket" {
  bucket = "bucket-prova"
}
