variable "repo_name" {
  description = "Name of the repositories that need a key."
  type        = string
}

resource "tls_private_key" "this" {
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "this" {
  title      = "${var.repo_name}-key"
  repository = var.repo_name
  key        = tls_private_key.this.public_key_openssh
  read_only  = false
}

resource "local_file" "this" {
  content  = tls_private_key.this.private_key_openssh
  filename = "${path.cwd}/${github_repository_deploy_key.this.title}.pem"

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ${self.filename}"
  }
}