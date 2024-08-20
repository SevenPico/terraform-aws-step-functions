locals {
  logging_enabled                 = module.context.enabled && try(var.logging_configuration["level"], null) != null && try(var.logging_configuration["level"], "OFF") != "OFF"
  create_aws_cloudwatch_log_group = module.context.enabled && (var.existing_aws_cloudwatch_log_group_arn == null || var.existing_aws_cloudwatch_log_group_arn == "")
  cloudwatch_log_group_arn        = local.create_aws_cloudwatch_log_group ? one(aws_cloudwatch_log_group.logs[*].arn) : var.existing_aws_cloudwatch_log_group_arn
  cloudwatch_log_name             = var.cloudwatch_log_group_name != null && var.cloudwatch_log_group_name != "" ? var.cloudwatch_log_group_name : module.logs_label.id
}

# ------------------------------------------------------------------------------
# Cloudwatch Logs Context
# ------------------------------------------------------------------------------
module "logs_label" {
  source  = "SevenPico/context/null"
  version = "2.0.0"

  attributes = ["logs"]

  context = module.context.self
  enabled = module.context.enabled && local.logging_enabled
}


# ------------------------------------------------------------------------------
# Cloudwatch Logs
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "logs" {
  count = module.logs_label.enabled ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]

    resources = ["*"]
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  count = local.create_aws_cloudwatch_log_group && local.logging_enabled ? 1 : 0

  name              = local.cloudwatch_log_name
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = module.logs_label.tags
}

resource "aws_cloudwatch_log_stream" "log_streams" {
  for_each       = toset(local.create_aws_cloudwatch_log_group && local.logging_enabled ? var.cloudwatch_log_stream_names : [])
  name           = each.value
  log_group_name = aws_cloudwatch_log_group.logs[0].name
}