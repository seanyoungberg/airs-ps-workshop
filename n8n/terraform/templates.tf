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


resource "local_file" "ollama_manifest" {
  content = templatefile(
    "${path.module}/../templates/ollama/ollama.yaml.tftpl",
    {
      SERVICE_ACCOUNT_NAME = local.ollama_service_account_name,
      BUCKET_NAME          = local.ollama_bucket_name
    }
  )
  filename = "${path.module}/../gen/ollama.yaml"
}

resource "local_file" "n8n_common_values_file" {
  content = templatefile(
    "${path.module}/../templates/n8n/common-values.yaml.tftpl",
    {
      DB_HOST = module.cloudsql.private_ip_address
    }
  )
  filename = "${path.module}/../gen/n8n-common-values.yaml"
}

resource "local_file" "n8n_service_values_file" {
  for_each = toset(["ClusterIP", "NodePort"])
  content = templatefile(
    "${path.module}/../templates/n8n/service-type.yaml.tftpl",
    {
      SERVICE_TYPE = each.value
    }
  )
  filename = "${path.module}/../gen/n8n-service-type-${lower(each.value)}.yaml"
}

# Generate NodePort with NEG annotation for GKE ingress
resource "local_file" "n8n_service_nodeport_neg_values_file" {
  content  = file("${path.module}/../templates/n8n/service-type-nodeport-neg.yaml.tftpl")
  filename = "${path.module}/../gen/n8n-service-type-nodeport-neg.yaml"
}

# Generate basic auth credentials for initial n8n setup
resource "random_password" "n8n_basic_auth_password" {
  length  = 16
  special = true
}

resource "local_file" "n8n_basic_auth_values_file" {
  content = templatefile(
    "${path.module}/../templates/n8n/basic-auth-values.yaml.tftpl",
    {
      BASIC_AUTH_USER     = "admin"
      BASIC_AUTH_PASSWORD = random_password.n8n_basic_auth_password.result
    }
  )
  filename = "${path.module}/../gen/n8n-basic-auth-values.yaml"

  provisioner "local-exec" {
    command = "echo 'N8N Basic Auth Credentials:\nUsername: admin\nPassword: ${random_password.n8n_basic_auth_password.result}' > ${path.module}/../gen/n8n-credentials.txt"
  }
}

resource "random_password" "n8n_owner_password" {
  length      = 20
  special     = true
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

resource "local_file" "n8n_owner_credentials_file" {
  content = templatefile(
    "${path.module}/../templates/n8n/owner-credentials.txt.tftpl",
    {
      OWNER_EMAIL    = var.n8n_owner_email
      OWNER_PASSWORD = random_password.n8n_owner_password.result
    }
  )
  filename = "${path.module}/../gen/n8n-owner-credentials.txt"
}

resource "local_file" "n8n_owner_bootstrap_manifest" {
  content = templatefile(
    "${path.module}/../templates/owner/owner-bootstrap.yaml.tftpl",
    {
      OWNER_EMAIL         = var.n8n_owner_email
      OWNER_FIRST_NAME    = var.n8n_owner_first_name
      OWNER_LAST_NAME     = var.n8n_owner_last_name
      OWNER_PASSWORD      = random_password.n8n_owner_password.result
      BASIC_AUTH_USER     = "admin"
      BASIC_AUTH_PASSWORD = random_password.n8n_basic_auth_password.result
      OWNER_SECRET_NAME   = "n8n-owner-bootstrap"
      OWNER_JOB_NAME      = "n8n-owner-bootstrap"
      N8N_SERVICE_HOST    = "n8n.default.svc.cluster.local"
      N8N_SERVICE_PORT    = 80
    }
  )
  filename = "${path.module}/../gen/n8n-owner-bootstrap.yaml"
}
