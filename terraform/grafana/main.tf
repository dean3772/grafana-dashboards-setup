terraform {
  required_providers {
    grafana = {
      source = "grafana/grafana"
      version = "~> 1.0"
    }
  }
}

provider "grafana" {
  url   = var.grafana_url
  auth  = var.grafana_auth_token
}

resource "grafana_dashboard" "podsnamespacecputimedashboard" {
  config_json = file("${path.module}/dashboards/podsnamespacecputimedashboard.json")
}

