locals {
  queue_name = var.fifo_queue ? "${var.queue_name}.fifo" : var.queue_name
  dlq_name   = var.fifo_queue ? "${var.queue_name}-dlq.fifo" : "${var.queue_name}-dlq"
}

resource "aws_sqs_queue" "this" {
  name                       = local.queue_name
  visibility_timeout_seconds = var.visibility_timeout
  message_retention_seconds  = var.message_retention
  max_message_size           = var.max_message_size
  delay_seconds              = var.delay_seconds
  receive_wait_time_seconds  = var.receive_wait_time

  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null
  deduplication_scope         = var.fifo_queue ? var.deduplication_scope : null
  fifo_throughput_limit       = var.fifo_queue ? var.fifo_throughput_limit : null

  sqs_managed_sse_enabled = var.kms_key_id == "" ? true : null
  kms_master_key_id       = var.kms_key_id != "" ? var.kms_key_id : null

  tags = var.tags
}

resource "aws_sqs_queue" "dlq" {
  count = var.create_dlq ? 1 : 0

  name                      = local.dlq_name
  message_retention_seconds = var.dlq_message_retention

  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null

  sqs_managed_sse_enabled = var.kms_key_id == "" ? true : null
  kms_master_key_id       = var.kms_key_id != "" ? var.kms_key_id : null

  tags = var.tags
}

resource "aws_sqs_queue_redrive_policy" "this" {
  count = var.create_dlq ? 1 : 0

  queue_url = aws_sqs_queue.this.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  })
}

resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  count = var.create_dlq ? 1 : 0

  queue_url = aws_sqs_queue.dlq[0].id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.this.arn]
  })
}
