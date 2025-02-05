variable "vpc_cidr" {
  type = string
}

variable "num_subnets" {
  type = number
}

variable "allowed_ips" {
  type = set(string)
}