variable "deploy_key" {
  description = "Whether to create a deploy key for the dev environment"
  type        = bool
  default     = false
}

variable "environments" {
  description = "A map of environments to create repos for"
  type        = set(string)
  default     = ["dev", "prod"]
  }
