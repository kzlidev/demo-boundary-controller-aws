# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# RDS password
#------------------------------------------------------------------------------
data "aws_secretsmanager_secret_version" "boundary_database_password" {
  secret_id = var.boundary_database_password_secret_arn
}

#------------------------------------------------------------------------------
# DB Subnet Group
#------------------------------------------------------------------------------
resource "aws_db_subnet_group" "boundary" {
  name       = "${var.friendly_name_prefix}-boundary-db-subnet-group"
  subnet_ids = var.rds_subnet_ids

  tags = merge(
    { "Name" = "${var.friendly_name_prefix}-boundary-db-subnet-group" },
    var.common_tags
  )
}

#------------------------------------------------------------------------------
# RDS Aurora (PostgreSQL)
#------------------------------------------------------------------------------
resource "aws_db_instance" "postgres" {
  identifier                = "${var.friendly_name_prefix}-boundary-rds-cluster-${data.aws_region.current.name}"
  allocated_storage         = var.rds_allocated_storage
  port                      = 5432
  engine                    = "postgres"
  db_name                   = var.boundary_database_name
  engine_version            = var.rds_engine_version
  instance_class            = var.rds_instance_class
  username                  = var.boundary_database_user
  password                  = data.aws_secretsmanager_secret_version.boundary_database_password.secret_string
  parameter_group_name      = aws_db_parameter_group.boundary.id
  skip_final_snapshot       = var.rds_skip_final_snapshot
  publicly_accessible       = false
  db_subnet_group_name      = aws_db_subnet_group.boundary.name
  vpc_security_group_ids    = [aws_security_group.rds_allow_ingress.id]
  storage_encrypted         = var.rds_storage_encrypted
  kms_key_id                = var.rds_kms_key_arn
  backup_retention_period   = var.rds_backup_retention_period
  backup_window             = var.rds_preferred_backup_window
  maintenance_window        = var.rds_preferred_maintenance_window
  final_snapshot_identifier = "${var.friendly_name_prefix}-boundary-rds-final-snapshot-${data.aws_region.current.name}"
  apply_immediately         = var.rds_apply_immediately
  multi_az                  = var.rds_multi_az

  tags = merge(
    { "Name" = "${var.friendly_name_prefix}-boundary-rds-cluster-${data.aws_region.current.name}" },
    { "Description" = "Boundary RDS PostgreSQL database cluster." },
    var.common_tags
  )
}

resource "aws_rds_cluster_parameter_group" "boundary" {
  name        = "${var.friendly_name_prefix}-boundary-rds-cluster-parameter-group-${data.aws_region.current.name}"
  family      = var.rds_parameter_group_family
  description = "Boundary RDS Aurora PostgreSQL database cluster parameter group."
}

resource "aws_db_parameter_group" "boundary" {
  name        = "${var.friendly_name_prefix}-boundary-rds-db-parameter-group-${data.aws_region.current.name}"
  family      = var.rds_parameter_group_family
  description = "Boundary RDS Aurora PostgreSQL database cluster instance parameter group."
}

#------------------------------------------------------------------------------
# RDS Security Group
#------------------------------------------------------------------------------
resource "aws_security_group" "rds_allow_ingress" {
  name   = "${var.friendly_name_prefix}-boundary-rds-allow-ingress"
  vpc_id = var.vpc_id
  tags   = merge({ "Name" = "${var.friendly_name_prefix}-boundary-rds-allow-ingress" }, var.common_tags)
}

resource "aws_security_group_rule" "rds_allow_ingress_from_ec2" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_allow_ingress.id
  description              = "Allow TCP/5432 (PostgreSQL) inbound to RDS Aurora from Boundary EC2 instances."

  security_group_id = aws_security_group.rds_allow_ingress.id
}

