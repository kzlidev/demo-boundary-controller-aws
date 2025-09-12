# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.47.0"
    }
  }
}

provider "aws" {
  region = var.region # change to your desired region
  default_tags {
    tags = var.common_tags
  }
}

module "boundary" {
  source = "../"

  # Common
  friendly_name_prefix = var.friendly_name_prefix
  common_tags          = var.common_tags

  # Pre-requisites
  boundary_license_secret_arn           = aws_secretsmanager_secret.sm_boundary_license.arn
  boundary_tls_cert_secret_arn          = aws_secretsmanager_secret.sm_boundary_tls_cert.arn
  boundary_tls_privkey_secret_arn       = aws_secretsmanager_secret.sm_boundary_tls_cert_key.arn
  boundary_tls_ca_bundle_secret_arn     = aws_secretsmanager_secret.sm_boundary_tls_ca_bundle.arn
  boundary_database_password_secret_arn = aws_secretsmanager_secret.sm_boundary_database_password.arn

  # Boundary configuration settings
  boundary_fqdn            = var.boundary_fqdn
  boundary_version         = var.boundary_version
  enable_session_recording = var.enable_session_recording

  # Networking
  vpc_id                           = aws_vpc.my_vpc.id
  api_lb_subnet_ids                = [aws_subnet.public_subnet_1.id]
  api_lb_is_internal               = false
  cluster_lb_subnet_ids            = [aws_subnet.public_subnet_1.id]  # Should be private
  controller_subnet_ids            = [aws_subnet.public_subnet_1.id]  # Should be private
  rds_subnet_ids                   = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  cidr_allow_ingress_boundary_443  = [var.vpc_cidr, "0.0.0.0/0"]
  cidr_allow_ingress_boundary_9201 = [var.vpc_cidr]
  #  sg_allow_ingress_boundary_9201   = var.sg_allow_ingress_boundary_9201
  cidr_allow_ingress_ec2_ssh_rdp       = [var.vpc_cidr, "3.0.5.32/29"] # Instance Connect IP

  # DNS (optional)
  create_route53_boundary_dns_record = true
  route53_boundary_hosted_zone_name  = var.route53_boundary_hosted_zone_name

  # Compute
  ec2_os_distro      = var.ec2_os_distro
  ec2_ssh_key_pair   = var.ec2_ssh_key_pair
  asg_instance_count = var.asg_instance_count
  ec2_instance_size  = var.ec2_instance_size

  # Database
  rds_skip_final_snapshot   = var.rds_skip_final_snapshot
  rds_instance_class = var.rds_aurora_instance_class

  # IAM
  ec2_allow_ssm = var.ec2_allow_ssm

  # KMS
  create_bsr_kms_key = var.create_bsr_kms_key
}
