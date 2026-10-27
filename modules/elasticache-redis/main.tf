resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.identifier}-redis"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.identifier}-redis"
  })
}

resource "aws_security_group" "this" {
  name_prefix = "${var.identifier}-redis-"
  description = "Allow Redis from VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "Redis from VPC"
    from_port   = 6379
    to_port     = 6379
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
    Name = "${var.identifier}-redis"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.identifier
  description          = "${var.identifier} Redis cluster"
  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_clusters   = var.num_cache_clusters
  port                 = 6379

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.this.id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = var.transit_encryption_enabled
  automatic_failover_enabled = var.num_cache_clusters > 1

  snapshot_retention_limit = var.snapshot_retention_limit
  maintenance_window       = var.maintenance_window
  snapshot_window          = var.snapshot_window

  auto_minor_version_upgrade = true
  apply_immediately          = var.apply_immediately

  tags = var.tags
}
