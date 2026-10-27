output "alb_controller_role_arn" {
  description = "IAM role ARN for the ALB controller"
  value       = module.alb_controller_irsa.iam_role_arn
}
