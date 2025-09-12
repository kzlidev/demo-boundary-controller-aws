resource "tls_private_key" "rdp_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "rdp_key_pair" {
  key_name   = "${var.friendly_name_prefix}-rdp-key-pair"
  public_key = tls_private_key.rdp_key_pair.public_key_openssh
}

resource "local_file" "rdp_private_key_openssh" {
  filename = "${path.root}/tmp/rdp_private_key"
  content  = tls_private_key.rdp_key_pair.private_key_pem
}

resource "aws_security_group" "rdp_sg" {
  name        = "rdp-access"
  description = "Allow RDP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "RDP from anywhere (adjust as needed)"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.cidr_allow_ingress_ec2_ssh_rdp
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "windows_rdp" {
  ami                    = "ami-0d6a6fdea11ea0f9f" # Microsoft Windows Server 2025 Base
  instance_type          = "t3.small"
  subnet_id              = var.api_lb_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.rdp_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.boundary_ec2.name
  key_name               = aws_key_pair.rdp_key_pair.key_name
  #  associate_public_ip_address = true

  tags = {
    Name = "${var.friendly_name_prefix}-windows-rdp-boundary-client"
  }

  user_data = <<-EOF
<powershell>
# Install AWS PowerShell module if not present
if (-not (Get-Module -ListAvailable -Name AWS.Tools.SecretsManager)) {
    Install-Module -Name AWS.Tools.SecretsManager -Force -Scope AllUsers
}

Import-Module AWS.Tools.SecretsManager

# Define variables
$secretName = "${var.boundary_tls_ca_bundle_secret_arn}"
$region = "ap-southeast-1"
$tempCertPath = "C:\temp\ca-cert.crt"

if (-not (Test-Path "C:\temp")) {
    New-Item -Path "C:\temp" -ItemType Directory
}

# Get secret value from Secrets Manager
$secret = Get-SECSecretValue -SecretId $secretName -Region $region

$decodedBytes = [Convert]::FromBase64String($secret.SecretString)
$certContent = [Text.Encoding]::Utf8.GetString($decodedBytes)

$certContent | Out-File -FilePath $tempCertPath -Encoding ascii
Write-Output $certContent

# Import cert to Trusted Root Certification Authorities (Local Machine)
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($tempCertPath)
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root","LocalMachine")
$store.Open("ReadWrite")
$store.Add($cert)
$store.Close()

# Clean up
Remove-Item $tempCertPath -Force
</powershell>
  EOF
}
