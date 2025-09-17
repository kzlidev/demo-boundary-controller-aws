# Create private key for https certificate
resource "tls_private_key" "hashicats_private_key" {
  algorithm = "RSA"
}

resource "local_file" "hashicats_private_key" {
  content  = tls_private_key.hashicats_private_key.private_key_pem
  filename = "${path.module}/tmp/hashicats_private_key.key"
}

# Create CSR for for hashicats certificate
resource "tls_cert_request" "hashicats_csr" {

  private_key_pem = tls_private_key.hashicats_private_key.private_key_pem

  dns_names = ["http.boundary", "https.boundary", "*.boundary", "*.${var.route53_boundary_hosted_zone_name}"]

  subject {
    country             = "SG"
    province            = "Singapore"
    locality            = "Singapore"
    common_name         = "hashicats"
    organization        = "Demo Organization"
    organizational_unit = "Development"
  }
}

# Sign Server Certificate by Private CA
resource "tls_locally_signed_cert" "hashicats_signed_cert" {
  // CSR by the hashicats servers
  cert_request_pem = tls_cert_request.hashicats_csr.cert_request_pem
  // CA Private key
  ca_private_key_pem = tls_private_key.ca_private_key.private_key_pem
  // CA certificate
  ca_cert_pem = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 4380

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

resource "local_file" "hashicats_cert" {
  content  = tls_locally_signed_cert.hashicats_signed_cert.cert_pem
  filename = "${path.module}/tmp/hashicats.cert"
}
