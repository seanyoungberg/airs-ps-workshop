# Copyright 2025 Google LLC
#
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

# Variables for cert-ingress configuration
variable "cert_ingress_enabled" {
  description = "Enable certificate and ingress creation"
  type        = bool
  default     = true
}

variable "cert_ingress_name" {
  description = "Name prefix for cert-ingress resources"
  type        = string
  default     = "workshop"
}

variable "use_sslip_io" {
  description = "Use sslip.io for automatic DNS resolution"
  type        = bool
  default     = true
}

variable "custom_domain" {
  description = "Custom domain to use instead of sslip.io"
  type        = string
  default     = ""
}

# Random suffix for unique resource names
resource "random_string" "cert_ingress_suffix" {
  count   = var.cert_ingress_enabled ? 1 : 0
  length  = 4
  special = false
  upper   = false
}

# Static IP for ingress
resource "google_compute_global_address" "cert_ingress_ip" {
  count        = var.cert_ingress_enabled ? 1 : 0
  provider     = google-beta
  project      = var.project_id
  name         = "${var.cert_ingress_name}-ip-${random_string.cert_ingress_suffix[0].result}"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

# Locals for domain calculation
locals {
  cert_ingress_domain = var.cert_ingress_enabled ? (
    var.custom_domain != "" ? var.custom_domain : 
    var.use_sslip_io ? "${google_compute_global_address.cert_ingress_ip[0].address}.sslip.io" : 
    ""
  ) : ""
  
  cert_ingress_ip = var.cert_ingress_enabled ? google_compute_global_address.cert_ingress_ip[0].address : ""
  cert_ingress_ip_name = var.cert_ingress_enabled ? google_compute_global_address.cert_ingress_ip[0].name : ""
}

# Generate managed certificate manifest
resource "local_file" "cert_ingress_managed_cert" {
  count = var.cert_ingress_enabled ? 1 : 0
  content = templatefile(
    "${path.module}/../templates/cert-ingress/managed-cert.yaml.tftpl",
    {
      CERT_NAME = "${var.cert_ingress_name}-managed-cert"
      DOMAIN    = local.cert_ingress_domain
    }
  )
  filename = "${path.module}/../gen/cert-ingress-managed-cert.yaml"
}

# Generate ingress manifest for single app (n8n)
resource "local_file" "cert_ingress_ingress" {
  count = var.cert_ingress_enabled ? 1 : 0
  content = templatefile(
    "${path.module}/../templates/cert-ingress/ingress-single.yaml.tftpl",
    {
      INGRESS_NAME         = "${var.cert_ingress_name}-ingress"
      STATIC_IP_NAME       = local.cert_ingress_ip_name
      MANAGED_CERT_NAME    = "${var.cert_ingress_name}-managed-cert"
      BACKEND_SERVICE_NAME = "n8n"
      BACKEND_SERVICE_PORT = 80
    }
  )
  filename = "${path.module}/../gen/cert-ingress-ingress.yaml"
}

# Output the domain and IP for easy access
output "cert_ingress_domain" {
  value       = local.cert_ingress_domain
  description = "Domain for accessing applications via HTTPS"
}

output "cert_ingress_ip" {
  value       = local.cert_ingress_ip
  description = "Static IP address for the ingress"
}

output "cert_ingress_url" {
  value       = var.cert_ingress_enabled ? "https://${local.cert_ingress_domain}" : ""
  description = "Full URL for accessing the application"
}