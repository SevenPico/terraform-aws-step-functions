locals {
  default_principals = {
    Service = [
      "states.${local.region}.amazonaws.com"
    ]
  }

  policy_documents = concat(
    var.policy_documents,
    module.logs_label.enabled ? [data.aws_iam_policy_document.logs[0].json] : []
  )

  use_fullname = var.role_name == null
}


# ------------------------------------------------------------------------------
# Iam Role Context
# ------------------------------------------------------------------------------
module "iam_role_context" {
  source     = "registry.terraform.io/SevenPico/context/null"
  version    = "2.0.0"
  context    = module.context.self
  attributes = ["role"]
}


# ------------------------------------------------------------------------------
# Iam Role
# ------------------------------------------------------------------------------
module "iam_role" {
  source  = "registry.terraform.io/SevenPicoForks/iam-role/aws"
  version = "2.0.0"
  context = module.iam_role_context.self

  assume_role_actions      = var.assume_role_actions
  assume_role_conditions   = var.assume_role_conditions
  instance_profile_enabled = var.instance_profile_enabled
  managed_policy_arns      = var.managed_policy_arns
  max_session_duration     = var.max_session_duration
  path                     = var.role_path
  permissions_boundary     = var.role_permissions_boundary
  policy_description       = var.policy_description
  policy_document_count    = length(local.policy_documents)
  policy_documents         = local.policy_documents
  principals               = merge(local.default_principals, var.principals)
  role_description         = var.role_description
  tags                     = module.context.tags
  tags_enabled             = var.tags_enabled
  name                     = var.role_name
  use_fullname             = local.use_fullname
}
