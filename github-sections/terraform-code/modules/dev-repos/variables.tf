variable "repo_max" {
  type        = number
  description = "Number of repositories."
  default     = 2
  validation {
    condition     = var.repo_max <= 10
    error_message = "Do not deploy more than 10 repositories."
  }
}

variable "env" {
  type        = string
  description = "Deployment environment."
  validation {
    condition     = contains(["dev", "prod"], var.env)
    error_message = "Env must be 'dev' or 'prod'"
  }
}

variable "repos" {
  type        = map(any)
  description = "Repositories."
  validation {
    condition     = length(var.repos) <= var.repo_max
    error_message = "Please do not deploy more repos than the repo_max allows."
  }
}

variable "run_provisioners" {
  type        = bool
  description = "Whether to run provisioners."
  default     = false
}

# variable "visibility" {
#     type = string
#     description = "Visibility of the repo."
#     default = var.env == "dev" ? "private" : "public"
# }