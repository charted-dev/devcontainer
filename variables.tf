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

variable "dotfiles_repo" {
  description = "Repository URL to the dotfiles configuration"
  default     = ""
  type        = string
}

variable "use_host_kubeconfig" {
  description = "Whether to use the host's Kubernetes configuration to provision or not"
  default     = false
  type        = bool
}

variable "kube_context" {
  description = "Configuration cluster context to use. [default=null]"
  default     = null
  type        = string
}

variable "namespace" {
  description = "Namespace to use to configure the Kubernetes pod"
  default     = "august"
  type        = string
}

variable "dir" {
  description = "Relative (or absolute) directory to the home directory if not using Noel's Coder Images"
  default     = "/home/noel"
  type        = string
}

variable "docker_image" {
  description = "Docker image to use to provision the Kubernetes pod"
  default     = "registry.floofy.dev/noelware/charted/coder:latest"
  type        = string
}
