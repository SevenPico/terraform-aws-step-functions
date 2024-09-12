variable "step_function_name" {
  type        = string
  description = "The name of the Step Function. If not provided, a name will be generated from the context."
  default     = null
}

variable "definition" {
  type        = any
  description = "The Amazon States Language definition for the Step Function. Refer to https://docs.aws.amazon.com/step-functions/latest/dg/concepts-amazon-states-language.html for more details/."
}

variable "tracing_enabled" {
  type        = bool
  description = "When set to true, AWS X-Ray tracing is enabled. Make sure the State Machine has the correct IAM policies for logging."
  default     = false
}

variable "type" {
  type        = string
  description = "Determines whether a Standard or Express state machine is created. The default is STANDARD. Valid Values: STANDARD, EXPRESS."
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "EXPRESS"], upper(var.type))
    error_message = "Step Function type must be either STANDARD or EXPRESS."
  }
}

variable "existing_aws_cloudwatch_log_group_arn" {
  type        = string
  description = "The Amazon Resource Name (ARN) of the existing CloudWatch Log Group to use for the Step Function. If not provided, a new CloudWatch Log Group will be created."
  default     = null
}

variable "logging_configuration" {
  type = object({
    log_destination        = optional(string)
    include_execution_data = bool
    level                  = string
  })
  description = "Defines what execution history events are logged and where they are logged."
  default = {
    include_execution_data = false
    level                  = "OFF"
  }
}

variable "cloudwatch_log_group_name" {
  type        = string
  description = "Name of Cloudwatch Logs Group to use. If not provided, a name will be generated from the context."
  default     = null
}

variable "cloudwatch_log_group_retention_in_days" {
  type        = number
  description = "Specifies the number of days to retain log events in the Log Group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
  default     = 90
}

variable "cloudwatch_log_group_kms_key_id" {
  type        = string
  description = "The ARN of the KMS Key to use when encrypting log data."
  default     = null
}

variable "role_path" {
  type        = string
  description = "Path of the created IAM role."
  default     = null
}

variable "role_permissions_boundary" {
  type        = string
  description = "The ARN of the policy that is used to set the permissions boundary for the created IAM role."
  default     = null
}

variable "policy_documents" {
  type        = list(string)
  description = "List of JSON IAM policy documents."
  default     = []
}

variable "managed_policy_arns" {
  type        = set(string)
  description = "List of managed policies to attach to created role."
  default     = []
}

variable "use_fullname" {
  type        = bool
  default     = true
  description = <<-EOT
  If set to 'true' then the full ID for the IAM role name (e.g. `[var.namespace]-[var.environment]-[var.stage]`) will be used.

  Otherwise, `var.name` will be used for the IAM role name.
  EOT
}

variable "role_name" {
  type = string
  description = "Custom name for step function's IAM role."
  default = null
}

variable "principals" {
  type        = map(list(string))
  description = "Map of service name as key and a list of ARNs to allow assuming the role as value (e.g. map(`AWS`, list(`arn:aws:iam:::role/admin`)))."
  default     = {}
}

variable "max_session_duration" {
  type        = number
  default     = 3600
  description = "The maximum session duration (in seconds) for the role. Can have a value from 1 hour to 12 hours."
}

variable "permissions_boundary" {
  type        = string
  default     = ""
  description = "ARN of the policy that is used to set the permissions boundary for the role."
}

variable "role_description" {
  type        = string
  description = "The description of the IAM role that is visible in the IAM role manager."
}

variable "policy_description" {
  type        = string
  default     = ""
  description = "The description of the IAM policy that is visible in the IAM policy manager."
}

variable "assume_role_actions" {
  type        = list(string)
  default     = ["sts:AssumeRole"]
  description = "The IAM action to be granted by the AssumeRole policy."
}

variable "assume_role_conditions" {
  type = list(object({
    test     = string
    variable = string
    values   = list(string)
  }))
  description = "List of conditions for the assume role policy."
  default     = []
}

variable "instance_profile_enabled" {
  type        = bool
  default     = false
  description = "Create EC2 Instance Profile for the role."
}

variable "path" {
  type        = string
  description = "Path to the role and policy. See [IAM Identifiers](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html) for more information."
  default     = "/"
}

variable "tags_enabled" {
  type        = string
  description = "Enable/disable tags on IAM roles and policies."
  default     = true
}

variable "cloudwatch_log_stream_names" {
  type        = list(string)
  description = "List of logstream names for step function's default log group."
  default     = []
}
