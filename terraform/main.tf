variable "environment" {
  default = "dev"
}

output "environment" {
  value = var.environment
}

resource "example" "test" {
  cidr = "0.0.0.0/0"
}
