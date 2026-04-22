variable "namespace" {
  type        = string
  description = "Namespace component of the generated resource name (e.g. organization short code)"
}

variable "stage" {
  type        = string
  description = "Stage component of the generated resource name (e.g. environment: prod, dev, stage)"
}

variable "name" {
  type        = string
  description = "Logical name of the WebACL. Combined with namespace and stage becomes the full AWS resource name"
}

variable "description" {
  type        = string
  default     = null
  description = "Free-form description attached to the WebACL"
}

variable "scope" {
  type        = string
  description = "Scope of the WebACL. CLOUDFRONT requires the AWS provider region to be us-east-1"

  validation {
    condition     = contains(["CLOUDFRONT", "REGIONAL"], var.scope)
    error_message = "scope must be CLOUDFRONT or REGIONAL."
  }
}

variable "default_action" {
  type        = string
  default     = "allow"
  description = "Default action for requests not matching any rule (allow or block)"

  validation {
    condition     = contains(["allow", "block"], var.default_action)
    error_message = "default_action must be allow or block."
  }
}

variable "visibility_config" {
  type = object({
    cloudwatch_metrics_enabled = bool
    metric_name                = string
    sampled_requests_enabled   = bool
  })
  description = "WebACL-level visibility_config (CloudWatch metrics and sampled request capture)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to the WebACL and to every IP set it creates"
}

variable "ip_set_reference_statement_rules" {
  type        = any
  default     = []
  description = <<-EOT
    Rules that match on an IP set. Each rule either declares an inline ip_set
    (addresses + ip_address_version) which the module creates, or references an
    existing ip set via statement.arn.

    Supported per-rule keys:
      name, priority,
      action (allow | block | count | captcha | challenge),
      statement.ip_set = { description, ip_address_version, addresses }
        OR
      statement.arn = <existing aws_wafv2_ip_set ARN>,
      visibility_config, captcha_config (optional)
  EOT
}

variable "byte_match_statement_rules" {
  type        = any
  default     = []
  description = <<-EOT
    Rules that match a literal string against a part of the request.

    Supported per-rule keys:
      name, priority,
      action (allow | block | count | captcha | challenge),
      statement = {
        positional_constraint (EXACTLY | STARTS_WITH | ENDS_WITH | CONTAINS | CONTAINS_WORD),
        search_string,
        field_to_match = one of { uri_path = true, single_header = { name }, method = true, query_string = true, body = true, all_query_arguments = true, single_query_argument = { name } },
        text_transformation = [{ priority, type }]
      },
      visibility_config, captcha_config (optional)
  EOT
}

variable "regex_match_statement_rules" {
  type        = any
  default     = []
  description = <<-EOT
    Rules that match a regular expression against a part of the request.

    Supported per-rule keys:
      name, priority,
      action (allow | block | count | captcha | challenge),
      statement = {
        regex_string,
        field_to_match = one of { uri_path = true, single_header = { name }, method = true, query_string = true, body = true, all_query_arguments = true, single_query_argument = { name } },
        text_transformation = [{ priority, type }]
      },
      visibility_config, captcha_config (optional)
  EOT
}

variable "managed_rule_group_statement_rules" {
  type        = any
  default     = []
  description = <<-EOT
    Rules that reference an AWS or marketplace managed rule group.

    Supported per-rule keys:
      name, priority,
      override_action (count | none, default none),
      statement = { name, vendor_name, version (optional) },
      visibility_config
  EOT
}
