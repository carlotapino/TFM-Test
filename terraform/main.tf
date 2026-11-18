provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "test" {
  name        = "test"
  description = "Test security group"
  # vpc_id    = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "mi-bucket-de-prueba-12345"
}

resource "aws_kms_key" "mykey" {
  description             = "Clave para cifrar el bucket S3"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_s3_bucket_public_access_block" "good_example" {
  bucket                  = aws_s3_bucket.example.id
  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
