locals {
  logging_configuration = {
    include_execution_data = true
    level                  = "ALL"
  }

  # https://docs.aws.amazon.com/step-functions/latest/dg/concepts-amazon-states-language.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/connect-parameters.html
  definition = {
    "Comment" = "Test Step Function"
    "StartAt" = "Hello"
    "States" = {
      "Hello" = {
        "Type"   = "Pass"
        "Result" = "Hello"
        "Next"   = "World"
      },
      "World" = {
        "Type"   = "Pass"
        "Result" = "World"
        "Next"   = "Send message to SQS"
      },
      # https://docs.aws.amazon.com/step-functions/latest/dg/connect-sqs.html
      "Send message to SQS" = {
        "Type"     = "Task"
        "Resource" = "arn:aws:states:::sqs:sendMessage"
        "Parameters" = {
          "QueueUrl"    = module.context.enabled ? aws_sqs_queue.default[0].url : ""
          "MessageBody" = "Hello World"
        }
        "Next" = "Publish to SNS"
      }
      # https://docs.aws.amazon.com/step-functions/latest/dg/connect-sns.html
      "Publish to SNS" = {
        "Type"     = "Task",
        "Resource" = "arn:aws:states:::sns:publish"
        "Parameters" = {
          "TopicArn" = module.sns.sns_topic_arn
          "Message"  = "Hello World"
        }
        "End" = true
      }
    }
  }

  # https://docs.aws.amazon.com/step-functions/latest/dg/service-integration-iam-templates.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/lambda-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/sns-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/sqs-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/xray-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/athena-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/batch-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/dynamo-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/ecs-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/glue-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/sagemaker-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/emr-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/codebuild-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/eks-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/api-gateway-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/stepfunctions-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/eventbridge-iam.html
  # https://docs.aws.amazon.com/step-functions/latest/dg/activities-iam.html
}

data "aws_iam_policy_document" "iam_policies" {
  count = module.context.enabled ? 1 : 0
  statement {
    sid    = "SnsAllowPublish"
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [
      module.sns.sns_topic_arn
    ]
  }

  statement {
    sid    = "SqsAllowSendMessage"
    effect = "Allow"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      module.context.enabled ? aws_sqs_queue.default[0].arn : "*"
    ]
  }
}

module "step_function" {
  source  = "../../"
  context = module.context.self

  type                                   = var.type
  step_function_name                     = var.step_function_name
  tracing_enabled                        = var.tracing_enabled
  cloudwatch_log_group_name              = null
  cloudwatch_log_group_retention_in_days = 90
  cloudwatch_log_group_kms_key_id        = null
  cloudwatch_log_stream_names            = ["emf"]
  role_description                       = "${module.context.id} role"
  role_path                              = "/"
  role_permissions_boundary              = null
  role_name                              = "custom-role"
  logging_configuration                  = local.logging_configuration
  definition                             = local.definition
  policy_description                     = "${module.context.id} role policy"
  policy_documents                       = module.context.enabled ? [data.aws_iam_policy_document.iam_policies[0].json] : []
  instance_profile_enabled               = false
}

module "sns" {
  source  = "cloudposse/sns-topic/aws"
  version = "0.20.2"

  sqs_dlq_enabled    = true
  fifo_topic         = true
  fifo_queue_enabled = true

  context = module.context.legacy
}


resource "aws_sqs_queue" "default" {
  count = module.context.enabled ? 1 : 0

  name                       = module.context.id
  fifo_queue                 = false
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400
  max_message_size           = 2048
  delay_seconds              = 90
  receive_wait_time_seconds  = 10

  tags = module.context.tags
}
