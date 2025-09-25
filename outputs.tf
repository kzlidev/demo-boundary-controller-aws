# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Boundary URLs
#------------------------------------------------------------------------------
output "boundary_url" {
  value       = "https://${var.boundary_fqdn}"
  description = "URL to access Boundary application based on value of `boundary_fqdn` input."
}

output "api_lb_dns_name" {
  value       = aws_lb.api.dns_name
  description = "DNS name of the Load Balancer for Boundary clients."
}

output "cluster_lb_dns_name" {
  value       = aws_lb.cluster.dns_name
  description = "DNS name of the Load Balancer for Boundary Ingress Workers."
}

#------------------------------------------------------------------------------
# RDS
#------------------------------------------------------------------------------
output "rds_arn" {
  value       = aws_db_instance.postgres.arn
  description = "ARN of Aurora DB."
}

output "rds_address" {
  value       = aws_db_instance.postgres.address
  description = "Address of RDS DB"
}

output "rds_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "RDS instance endpoint."
}

#------------------------------------------------------------------------------
# KMS
#------------------------------------------------------------------------------
output "created_kms_root_arn" {
  value       = try(aws_kms_key.root[0].arn, null)
  description = "The ARN of the created root KMS key"
}

output "created_kms_recovery_arn" {
  value       = try(aws_kms_key.recovery[0].arn, null)
  description = "The ARN of the created recovery KMS key"
}

output "created_kms_recovery_id" {
  value       = try(aws_kms_key.recovery[0].id, null)
  description = "The ID of the created recovery KMS key"
}

output "created_kms_worker_arn" {
  value       = try(aws_kms_key.worker[0].arn, null)
  description = "The ARN of the created worker KMS key"
}

output "created_kms_bsr_arn" {
  value       = try(aws_kms_key.bsr[0].arn, null)
  description = "The ARN of the created BSR KMS key"
}

output "provided_kms_root_arn" {
  value       = try(data.aws_kms_key.root[0].arn, null)
  description = "The ARN of the provided root KMS key"
}

output "provided_kms_recovery_arn" {
  value       = try(data.aws_kms_key.recovery[0].arn, null)
  description = "The ARN of the provided recovery  KMS key"
}

output "provided_kms_recovery_id" {
  value       = try(data.aws_kms_key.recovery[0].id, null)
  description = "The ID of the provided recovery KMS key"
}

output "provided_kms_worker_id" {
  value       = try(data.aws_kms_key.worker[0].arn, null)
  description = "The ID of the provided worker KMS key"
}

output "provided_kms_worker_arn" {
  value       = try(data.aws_kms_key.bsr[0].arn, null)
  description = "The ARN of the provided BSR KMS key"
}

#------------------------------------------------------------------------------
# S3
#------------------------------------------------------------------------------
output "bsr_s3_bucket_arn" {
  value       = try(aws_s3_bucket.boundary_session_recording[0].arn, null)
  description = "The arn of the S3 bucket for Boundary Session Recording."
}

output "bastion_ssh_aws_key_pair_name" {
  value = aws_key_pair.ssh_key_pair.key_name
  description = "Key pair name for SSH from bastion"
}