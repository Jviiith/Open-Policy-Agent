variable "region" {
  default = "us-east-1"
}
variable "vpc_cidr" {
  description = "vpc cidr block"
  default     = "10.123.0.0/16"
}

variable "public_cidr" {
  description = "public subnet cidr block"
  default     = "10.123.1.0/24"
}

variable "private_cidr" {
  description = "private subnet cidr block"
  default     = "10.123.2.0/24"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to vpc resource."
  default = {
    "environment" = "dev"
    "project"     = "opa"
  }
}
