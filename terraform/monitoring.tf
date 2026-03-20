# Monitoring and Alerting with CloudWatch and SNS

# SNS Topic for Alerts
resource "aws_sns_topic" "tech_challenge_alerts" {
  name              = "${var.cluster_name}-alerts"
  display_name      = "Tech Challenge Alerts"
  kms_master_key_id = "alias/aws/sns"

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-alerts"
    }
  )
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "tech_challenge_alerts" {
  arn = aws_sns_topic.tech_challenge_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "cloudwatch.amazonaws.com",
            "logs.amazonaws.com",
            "ecs-tasks.amazonaws.com"
          ]
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.tech_challenge_alerts.arn
      }
    ]
  })
}

# SNS Email Subscription (você precisa confirmar no email)
resource "aws_sns_topic_subscription" "tech_challenge_alerts_email" {
  topic_arn = aws_sns_topic.tech_challenge_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ===================================
# CLOUDWATCH ALARMS FOR API LATENCY
# ===================================

# Alarm: API Latency > 500ms
resource "aws_cloudwatch_metric_alarm" "api_latency_high" {
  alarm_name          = "${var.cluster_name}-api-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "http_server_requests_seconds_max"
  namespace           = "SpringBoot"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0.5" # 500ms
  alarm_description   = "Alert when API latency exceeds 500ms"
  alarm_actions       = [aws_sns_topic.tech_challenge_alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    Service     = "tech-challenge-app"
  }
}

# Alarm: API Error Rate > 5%
resource "aws_cloudwatch_metric_alarm" "api_error_rate_high" {
  alarm_name          = "${var.cluster_name}-api-error-rate-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "http_requests_total"
  namespace           = "SpringBoot"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5" # 5% error rate
  alarm_description   = "Alert when API error rate exceeds 5%"
  alarm_actions       = [aws_sns_topic.tech_challenge_alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    Status      = "5xx"
  }
}

# ===================================
# CLOUDWATCH ALARMS FOR KUBERNETES
# ===================================

# Alarm: Node CPU Utilization > 80%
resource "aws_cloudwatch_metric_alarm" "node_cpu_high" {
  alarm_name          = "${var.cluster_name}-node-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "node_cpu_utilization"
  namespace           = "AWS/EKS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when Node CPU utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.tech_challenge_alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
  }
}

# Alarm: Node Memory Utilization > 85%
resource "aws_cloudwatch_metric_alarm" "node_memory_high" {
  alarm_name          = "${var.cluster_name}-node-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "node_memory_utilization"
  namespace           = "AWS/EKS"
  period              = "60"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "Alert when Node memory utilization exceeds 85%"
  alarm_actions       = [aws_sns_topic.tech_challenge_alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
  }
}

# Alarm: Pod CPU Utilization > 80%
resource "aws_cloudwatch_metric_alarm" "pod_cpu_high" {
  alarm_name          = "${var.cluster_name}-pod-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "pod_cpu_utilization"
  namespace           = "AWS/EKS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when Pod CPU utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.tech_challenge_alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    Namespace   = "tech-challenge"
  }
}

# Alarm: Pod Memory Utilization > 85%
resource "aws_cloudwatch_metric_alarm" "pod_memory_high" {
  alarm_name          = "${var.cluster_name}-pod-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "pod_memory_utilization"
  namespace           = "AWS/EKS"
  period              = "60"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "Alert when Pod memory utilization exceeds 85%"
  alarm_actions       = [aws_sns_topic.tech_challenge_alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    Namespace   = "tech-challenge"
  }
}

# ===================================
# CLOUDWATCH ALARMS FOR DATABASE
# ===================================

# Alarm: RDS CPU Utilization > 80%
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "tech-challenge-db-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when RDS CPU utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.tech_challenge_alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = "tech-challenge-db"
  }
}

# Alarm: RDS Storage > 80%
resource "aws_cloudwatch_metric_alarm" "rds_storage_high" {
  alarm_name          = "tech-challenge-db-storage-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "20" # 20GB remaining = 80% used
  alarm_description   = "Alert when RDS free storage falls below 20GB"
  alarm_actions       = [aws_sns_topic.tech_challenge_alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = "tech-challenge-db"
  }
}

# Alarm: RDS Database Connections > 80
resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  alarm_name          = "tech-challenge-db-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when RDS connections exceed 80"
  alarm_actions       = [aws_sns_topic.tech_challenge_alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = "tech-challenge-db"
  }
}

# ===================================
# CLOUDWATCH ALARMS FOR LAMBDA
# ===================================

# Alarm: Lambda Function Errors > 5
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "tech-challenge-auth-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Alert when Lambda function errors exceed 5 in 5 minutes"
  alarm_actions       = [aws_sns_topic.tech_challenge_alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = "tech-challenge-auth"
  }
}

# Alarm: Lambda Duration > 3000ms
resource "aws_cloudwatch_metric_alarm" "lambda_duration_high" {
  alarm_name          = "tech-challenge-auth-lambda-duration-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Average"
  threshold           = "3000" # 3 seconds
  alarm_description   = "Alert when Lambda execution time exceeds 3 seconds"
  alarm_actions       = [aws_sns_topic.tech_challenge_alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = "tech-challenge-auth"
  }
}

# ===================================
# CLOUDWATCH LOG GROUPS
# ===================================

resource "aws_cloudwatch_log_group" "eks_cluster_logs" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 30

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-cluster-logs"
    }
  )
}

resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/eks/${var.cluster_name}/tech-challenge-app"
  retention_in_days = 30

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-app-logs"
    }
  )
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/tech-challenge-auth"
  retention_in_days = 30

  tags = merge(
    var.tags,
    {
      Name = "tech-challenge-auth-logs"
    }
  )
}

# ===================================
# CLOUDWATCH LOG FILTERS FOR ERRORS
# ===================================

# Log filter para detectar erros na aplicação
resource "aws_cloudwatch_log_metric_filter" "app_errors" {
  name           = "${var.cluster_name}-app-errors"
  log_group_name = aws_cloudwatch_log_group.app_logs.name
  filter_pattern = "[ERROR]"

  metric_transformation {
    name      = "AppErrorCount"
    namespace = "CustomMetrics"
    value     = "1"
  }
}

# Log filter para detectar exceções
resource "aws_cloudwatch_log_metric_filter" "app_exceptions" {
  name           = "${var.cluster_name}-app-exceptions"
  log_group_name = aws_cloudwatch_log_group.app_logs.name
  filter_pattern = "Exception"

  metric_transformation {
    name      = "AppExceptionCount"
    namespace = "CustomMetrics"
    value     = "1"
  }
}

# Alarm para erros detectados nos logs
resource "aws_cloudwatch_metric_alarm" "app_errors_alarm" {
  alarm_name          = "${var.cluster_name}-app-errors-detected"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "AppErrorCount"
  namespace           = "CustomMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Alert when more than 10 errors are detected in logs"
  alarm_actions       = [aws_sns_topic.tech_challenge_alerts.arn]
  treat_missing_data  = "notBreaching"
}

