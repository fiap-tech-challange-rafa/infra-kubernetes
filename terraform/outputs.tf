output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the cluster"
  value       = aws_eks_cluster.main.version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.cluster.id
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = aws_iam_role.cluster.arn
}

output "node_group_id" {
  description = "EKS node group ID"
  value       = aws_eks_node_group.main.id
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = aws_eks_node_group.main.status
}

output "node_group_iam_role_arn" {
  description = "IAM role ARN of the node group"
  value       = aws_iam_role.node.arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider"
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.tech_challenge_alerts.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic for alerts"
  value       = aws_sns_topic.tech_challenge_alerts.name
}

output "cloudwatch_log_group_eks" {
  description = "CloudWatch log group for EKS cluster"
  value       = aws_cloudwatch_log_group.eks_cluster_logs.name
}

output "cloudwatch_log_group_app" {
  description = "CloudWatch log group for application"
  value       = aws_cloudwatch_log_group.app_logs.name
}

output "cloudwatch_log_group_lambda" {
  description = "CloudWatch log group for Lambda"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "cloudwatch_alarms" {
  description = "List of CloudWatch alarms created"
  value = {
    api_latency        = aws_cloudwatch_metric_alarm.api_latency_high.alarm_name
    api_errors         = aws_cloudwatch_metric_alarm.api_error_rate_high.alarm_name
    node_cpu           = aws_cloudwatch_metric_alarm.node_cpu_high.alarm_name
    node_memory        = aws_cloudwatch_metric_alarm.node_memory_high.alarm_name
    pod_cpu            = aws_cloudwatch_metric_alarm.pod_cpu_high.alarm_name
    pod_memory         = aws_cloudwatch_metric_alarm.pod_memory_high.alarm_name
    rds_cpu            = aws_cloudwatch_metric_alarm.rds_cpu_high.alarm_name
    rds_storage        = aws_cloudwatch_metric_alarm.rds_storage_high.alarm_name
    rds_connections    = aws_cloudwatch_metric_alarm.rds_connections_high.alarm_name
    lambda_errors      = aws_cloudwatch_metric_alarm.lambda_errors.alarm_name
    lambda_duration    = aws_cloudwatch_metric_alarm.lambda_duration_high.alarm_name
    app_errors         = aws_cloudwatch_metric_alarm.app_errors_alarm.alarm_name
  }
}
