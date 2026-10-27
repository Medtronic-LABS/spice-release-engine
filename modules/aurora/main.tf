resource "aws_db_subnet_group" "this" {
  name       = "${var.cluster_name}-aurora"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-aurora"
  })
}

resource "aws_security_group" "this" {
  name_prefix = "${var.cluster_name}-aurora-"
  description = "Allow PostgreSQL from VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-aurora"
  })
}

resource "aws_rds_cluster" "this" {
  cluster_identifier     = "${var.cluster_name}-aurora"
  engine                 = "aurora-postgresql"
  engine_mode            = "provisioned"
  engine_version         = var.engine_version
  database_name          = var.database_name
  master_username        = var.master_username
  master_password        = var.master_password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  storage_encrypted      = true
  skip_final_snapshot    = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.cluster_name}-aurora-final"
  backup_retention_period   = var.backup_retention_period
  deletion_protection       = var.deletion_protection

  serverlessv2_scaling_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  tags = var.tags
}

resource "aws_rds_cluster_instance" "this" {
  count              = var.instance_count
  identifier         = "${var.cluster_name}-aurora-${count.index}"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version

  tags = var.tags
}
