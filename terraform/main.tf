variable "environment" {
  default = "dev"
}

output "environment" {
  value = var.environment
}

resource "example" "test" {
  passwd = "SuperSecret123"
  cidr   = "0.0.0.0/0"
}
