variable "environment" {
  default = "dev"
}

output "environment" {
  value = var.environment
}

resource "example" "test" {
  passwd = "SuperSecret123"
  cidr   = "0.0.0.0/0"
  KEY    = "1243refefespffodm"

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
