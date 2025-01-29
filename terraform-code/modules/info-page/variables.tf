variable "repos" {
  type = map(any)
}

variable "run_provisioners" {
  description = "Whether to run provisioners"
  type        = bool
  default     = false
}