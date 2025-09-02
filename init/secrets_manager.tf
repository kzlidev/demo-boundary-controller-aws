resource "aws_secretsmanager_secret" "sm_boundary_license" {
  name = "${var.friendly_name_prefix}-boundary-ent-license"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "sm_boundary_tls_cert" {
  name = "${var.friendly_name_prefix}-boundary-tls-cert"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "sm_boundary_tls_cert_key" {
  name = "${var.friendly_name_prefix}-boundary-tls-cert-key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "sm_boundary_tls_ca_bundle" {
  name = "${var.friendly_name_prefix}-boundary-tls-ca-bundle"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "sm_boundary_database_password" {
  name = "${var.friendly_name_prefix}-boundary-database-password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "sm_boundary_license" {
  secret_id     = aws_secretsmanager_secret.sm_boundary_license.id
  secret_string = file("${path.module}/../../boundary.hclic")
}

resource "aws_secretsmanager_secret_version" "sm_boundary_tls_cert" {
  secret_id     = aws_secretsmanager_secret.sm_boundary_tls_cert.id
  secret_string = base64encode(tls_locally_signed_cert.cluster_signed_cert.cert_pem)
}

resource "aws_secretsmanager_secret_version" "sm_boundary_tls_cert_key" {
  secret_id     = aws_secretsmanager_secret.sm_boundary_tls_cert_key.id
  secret_string = base64encode(tls_private_key.cluster_private_key.private_key_pem)
}

resource "aws_secretsmanager_secret_version" "sm_boundary_tls_ca_bundle" {
  secret_id     = aws_secretsmanager_secret.sm_boundary_tls_ca_bundle.id
  secret_string = base64encode(tls_self_signed_cert.ca_cert.cert_pem)
}

resource "aws_secretsmanager_secret_version" "sm_boundary_database_password" {
  secret_id     = aws_secretsmanager_secret.sm_boundary_database_password.id
  secret_string = var.boundary_database_password
}
