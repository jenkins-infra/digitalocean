# Copyright (C) 2020 Nicolas Lamirault <nicolas.lamirault@gmail.com>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

data "digitalocean_kubernetes_versions" "k8s" {
  version_prefix = var.kubernetes_version
}

data "digitalocean_sizes" "k8s" {
  # filter {
  #   key    = "slug"
  #   values = [var.size]
  # }

  filter {
    key    = "regions"
    values = [var.region]
  }

}

output "dok8s-versions" {
  value = data.digitalocean_kubernetes_versions.k8s.valid_versions
}
