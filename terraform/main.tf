provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------
# Security group
# ---------------------------------------------------------------
resource "aws_security_group" "test" {
  #checkov:skip=CKV2_AWS_5:Grupo de prueba, no se asocia a ninguna instancia
  name        = "test"
  description = "Test security group"
  # vpc_id    = aws_vpc.vpc.id

  ingress {
    description = "SSH desde la red interna"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
}

# ---------------------------------------------------------------
# Clave KMS
# ---------------------------------------------------------------
resource "aws_kms_key" "mykey" {
  description             = "Clave para cifrar el bucket S3"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AdministracionDeLaCuenta"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      }
    ]
  })
}

# ---------------------------------------------------------------
# Bucket principal
# ---------------------------------------------------------------
resource "aws_s3_bucket" "example" {
  #checkov:skip=CKV_AWS_144:Replicación entre regiones no necesaria en entorno de pruebas
  #checkov:skip=CKV2_AWS_62:Notificaciones de eventos no necesarias en entorno de pruebas
  bucket = "mi-bucket-de-prueba-12345"

  tags = {
    Owner = "mi-nombre-de-usuario"
  }
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

resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    id     = "limpieza"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.example]
}

resource "aws_s3_bucket_logging" "example" {
  bucket        = aws_s3_bucket.example.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "log/"
}

# ---------------------------------------------------------------
# Bucket de logs
# ---------------------------------------------------------------
resource "aws_s3_bucket" "logs" {
  #checkov:skip=CKV_AWS_18:Es el bucket de destino de logs; no se registra a sí mismo
  #checkov:skip=CKV_AWS_144:Replicación entre regiones no necesaria en entorno de pruebas
  #checkov:skip=CKV2_AWS_62:Notificaciones de eventos no necesarias en entorno de pruebas
  #checkov:skip=CKV_AWS_145:Los logs de acceso de S3 solo admiten cifrado SSE-S3 (AES256), no KMS
  #trivy:ignore:AVD-AWS-0089
  #trivy:ignore:AVD-AWS-0132
  bucket = "mi-bucket-de-prueba-12345-logs"
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "expirar-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = 365
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.logs]
}

# Permite que el servicio de logs de S3 escriba en el bucket de logs
data "aws_iam_policy_document" "logs" {
  statement {
    sid     = "PermitirLogsDeS3"
    effect  = "Allow"
    actions = ["s3:PutObject"]

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    resources = ["${aws_s3_bucket.logs.arn}/log/*"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.example.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.logs.json

  depends_on = [aws_s3_bucket_public_access_block.logs]
}
