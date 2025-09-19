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

output "gke_cluster_name" {
  value       = local.cluster_name
  description = "GKE cluster name"
}

output "gke_cluster_location" {
  value       = var.cluster_location
  description = "GKE cluster location"
}

output "project_id" {
  value       = var.project_id
  description = "GKE cluster location"
}

output "cloudsql_instance_ip" {
  value = module.cloudsql.private_ip_address
}


output "cloudsql_db_user" {
  value = var.cloudsql_db_user
}


#output "cloudsql_database_secret_name" {
#  value = var.cloudsql_database_secret_name
#}

output "cloudsql_db_name" {
  value = local.cloudsql_db_name
}

output "n8n_basic_auth_username" {
  value       = "admin"
  description = "Username for HTTP basic authentication in front of n8n"
}

output "n8n_basic_auth_password" {
  value       = nonsensitive(random_password.n8n_basic_auth_password.result)
  description = "Password for HTTP basic authentication in front of n8n"
}

output "n8n_owner_email" {
  value       = var.n8n_owner_email
  description = "Email address seeded for the n8n owner account"
}

output "n8n_owner_password" {
  value       = nonsensitive(random_password.n8n_owner_password.result)
  description = "Password generated for the n8n owner account"
}
