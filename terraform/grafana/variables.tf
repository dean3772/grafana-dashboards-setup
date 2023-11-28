variable "grafana_url" {
  description = "URL for the Grafana instance"
  type        = string
}

variable "grafana_auth_token" {
  description = "Auth token for Grafana provider"
  type        = string
  sensitive   = true
}
