variable "environment" {
  default = "dev"
}

output "environment" {
  value = var.environment
}
