resource "aws_secretsmanager_secret" "grafana" {
  name = "grafana"
}

resource "aws_secretsmanager_secret_version" "grafana" {
  secret_id     = aws_secretsmanager_secret.grafana.id
  secret_string = var.grafana_admin_password
}
