# coder-templates: Templates to aid development with Noelware's Charts Platform with Coder (https://coder.com)
# Copyright (c) 2022 Noelware <team@noelware.org>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "0.6.6"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }
  }
}

provider "kubernetes" {
  config_path    = var.use_host_kubeconfig == true ? "~/.kube/config" : null
  config_context = try(var.kube_context, "") != "" ? var.kube_context : null
}

data "coder_workspace" "me" {
}

resource "coder_agent" "main" {
  arch            = "amd64"
  dir             = var.dir
  os              = "linux"
  shutdown_script = <<-EOF
  #!/bin/bash

  # Shutdown Docker
  sudo systemctl stop docker
  EOF

  startup_script = <<-EOF
  #!/bin/bash

  # Install Docker on the container, since we need the client to connect to the
  # privileged pod.
  sudo apt update
  sudo apt install ca-certificates curl gnupg lsb-release

  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sudo systemctl enable --now docker
  sudo usermod -aG docker $USER

  # Now, let's enable dotfiles
  ${var.dotfiles_repo != "" ? "coder dotfiles -y ${var.dotfiles_repo}" : ""}
  git clone https://github.com/charted-dev/charted /home/noel/workspace
  EOF
}

resource "kubernetes_persistent_volume_claim" "charted-workspace" {
  metadata {
    namespace = var.namespace
    name      = "charted-server-workspace"
  }

  wait_until_bound = false
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
  }
}

resource "kubernetes_pod" "charted-server" {
  metadata {
    namespace = var.namespace
    name      = "charted-server"

    labels = {
      "k8s.noelware.cloud/component" = "cloud"
    }
  }

  spec {
    security_context {
      run_as_user = "1000"
      fs_group    = "1000"
    }

    container {
      name              = "charted-server"
      image             = var.docker_image
      command           = ["/bin/bash", "-c", coder_agent.main.init_script]
      image_pull_policy = "Always"

      env {
        name  = "CODER_ACCESS_URL"
        value = "https://coder.floofy.dev"
      }

      env {
        name  = "CODER_AGENT_TOKEN"
        value = coder_agent.main.token
      }

      volume_mount {
        mount_path = "/home/noel"
        read_only  = false
        name       = "workspace"
      }

      security_context {
        run_as_user = "1000"
      }
    }

    volume {
      name = "workspace"
      persistent_volume_claim {
        claim_name = "charted-workspace"
        read_only  = false
      }
    }
  }
}
