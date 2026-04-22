locals {
  id = format("%s-%s-%s", var.namespace, var.stage, var.name)

  base_tags = merge(
    var.tags,
    {
      Namespace = var.namespace
      Stage     = var.stage
    },
  )

  ip_set_reference_statement_rules = var.ip_set_reference_statement_rules != null ? {
    for rule in var.ip_set_reference_statement_rules :
    format("%s-ip-set", rule.name) => rule
  } : {}

  byte_match_statement_rules = var.byte_match_statement_rules != null ? {
    for rule in var.byte_match_statement_rules :
    rule.name => rule
  } : {}

  regex_match_statement_rules = var.regex_match_statement_rules != null ? {
    for rule in var.regex_match_statement_rules :
    rule.name => rule
  } : {}

  managed_rule_group_statement_rules = var.managed_rule_group_statement_rules != null ? {
    for rule in var.managed_rule_group_statement_rules :
    rule.name => rule
  } : {}
}

resource "aws_wafv2_web_acl" "default" {
  count = 1

  name        = local.id
  description = var.description
  scope       = var.scope
  tags        = merge(local.base_tags, { Name = local.id })

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.visibility_config.cloudwatch_metrics_enabled
    metric_name                = var.visibility_config.metric_name
    sampled_requests_enabled   = var.visibility_config.sampled_requests_enabled
  }

  dynamic "rule" {
    for_each = local.ip_set_reference_statement_rules

    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
        dynamic "captcha" {
          for_each = rule.value.action == "captcha" ? [1] : []
          content {}
        }
        dynamic "challenge" {
          for_each = rule.value.action == "challenge" ? [1] : []
          content {}
        }
      }

      statement {
        ip_set_reference_statement {
          arn = try(rule.value.statement.arn, aws_wafv2_ip_set.default[rule.key].arn)
        }
      }

      dynamic "visibility_config" {
        for_each = lookup(rule.value, "visibility_config", null) != null ? [rule.value.visibility_config] : []
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = visibility_config.value.metric_name
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }

      dynamic "captcha_config" {
        for_each = lookup(rule.value, "captcha_config", null) != null ? [rule.value.captcha_config] : []
        content {
          immunity_time_property {
            immunity_time = captcha_config.value.immunity_time_property.immunity_time
          }
        }
      }
    }
  }

  dynamic "rule" {
    for_each = local.byte_match_statement_rules

    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
        dynamic "captcha" {
          for_each = rule.value.action == "captcha" ? [1] : []
          content {}
        }
        dynamic "challenge" {
          for_each = rule.value.action == "challenge" ? [1] : []
          content {}
        }
      }

      statement {
        byte_match_statement {
          positional_constraint = rule.value.statement.positional_constraint
          search_string         = rule.value.statement.search_string

          field_to_match {
            dynamic "all_query_arguments" {
              for_each = lookup(rule.value.statement.field_to_match, "all_query_arguments", null) != null ? [1] : []
              content {}
            }
            dynamic "body" {
              for_each = lookup(rule.value.statement.field_to_match, "body", null) != null ? [1] : []
              content {}
            }
            dynamic "method" {
              for_each = lookup(rule.value.statement.field_to_match, "method", null) != null ? [1] : []
              content {}
            }
            dynamic "query_string" {
              for_each = lookup(rule.value.statement.field_to_match, "query_string", null) != null ? [1] : []
              content {}
            }
            dynamic "uri_path" {
              for_each = lookup(rule.value.statement.field_to_match, "uri_path", null) != null ? [1] : []
              content {}
            }
            dynamic "single_header" {
              for_each = lookup(rule.value.statement.field_to_match, "single_header", null) != null ? [rule.value.statement.field_to_match.single_header] : []
              content {
                name = single_header.value.name
              }
            }
            dynamic "single_query_argument" {
              for_each = lookup(rule.value.statement.field_to_match, "single_query_argument", null) != null ? [rule.value.statement.field_to_match.single_query_argument] : []
              content {
                name = single_query_argument.value.name
              }
            }
          }

          dynamic "text_transformation" {
            for_each = rule.value.statement.text_transformation
            content {
              priority = text_transformation.value.priority
              type     = text_transformation.value.type
            }
          }
        }
      }

      dynamic "visibility_config" {
        for_each = lookup(rule.value, "visibility_config", null) != null ? [rule.value.visibility_config] : []
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = visibility_config.value.metric_name
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }

      dynamic "captcha_config" {
        for_each = lookup(rule.value, "captcha_config", null) != null ? [rule.value.captcha_config] : []
        content {
          immunity_time_property {
            immunity_time = captcha_config.value.immunity_time_property.immunity_time
          }
        }
      }
    }
  }

  dynamic "rule" {
    for_each = local.regex_match_statement_rules

    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
        dynamic "captcha" {
          for_each = rule.value.action == "captcha" ? [1] : []
          content {}
        }
        dynamic "challenge" {
          for_each = rule.value.action == "challenge" ? [1] : []
          content {}
        }
      }

      statement {
        regex_match_statement {
          regex_string = rule.value.statement.regex_string

          field_to_match {
            dynamic "all_query_arguments" {
              for_each = lookup(rule.value.statement.field_to_match, "all_query_arguments", null) != null ? [1] : []
              content {}
            }
            dynamic "body" {
              for_each = lookup(rule.value.statement.field_to_match, "body", null) != null ? [1] : []
              content {}
            }
            dynamic "method" {
              for_each = lookup(rule.value.statement.field_to_match, "method", null) != null ? [1] : []
              content {}
            }
            dynamic "query_string" {
              for_each = lookup(rule.value.statement.field_to_match, "query_string", null) != null ? [1] : []
              content {}
            }
            dynamic "uri_path" {
              for_each = lookup(rule.value.statement.field_to_match, "uri_path", null) != null ? [1] : []
              content {}
            }
            dynamic "single_header" {
              for_each = lookup(rule.value.statement.field_to_match, "single_header", null) != null ? [rule.value.statement.field_to_match.single_header] : []
              content {
                name = single_header.value.name
              }
            }
            dynamic "single_query_argument" {
              for_each = lookup(rule.value.statement.field_to_match, "single_query_argument", null) != null ? [rule.value.statement.field_to_match.single_query_argument] : []
              content {
                name = single_query_argument.value.name
              }
            }
          }

          dynamic "text_transformation" {
            for_each = rule.value.statement.text_transformation
            content {
              priority = text_transformation.value.priority
              type     = text_transformation.value.type
            }
          }
        }
      }

      dynamic "visibility_config" {
        for_each = lookup(rule.value, "visibility_config", null) != null ? [rule.value.visibility_config] : []
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = visibility_config.value.metric_name
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }

      dynamic "captcha_config" {
        for_each = lookup(rule.value, "captcha_config", null) != null ? [rule.value.captcha_config] : []
        content {
          immunity_time_property {
            immunity_time = captcha_config.value.immunity_time_property.immunity_time
          }
        }
      }
    }
  }

  dynamic "rule" {
    for_each = local.managed_rule_group_statement_rules

    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        dynamic "count" {
          for_each = lookup(rule.value, "override_action", "none") == "count" ? [1] : []
          content {}
        }
        dynamic "none" {
          for_each = lookup(rule.value, "override_action", "none") != "count" ? [1] : []
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.statement.name
          vendor_name = rule.value.statement.vendor_name
          version     = lookup(rule.value.statement, "version", null)
        }
      }

      dynamic "visibility_config" {
        for_each = lookup(rule.value, "visibility_config", null) != null ? [rule.value.visibility_config] : []
        content {
          cloudwatch_metrics_enabled = lookup(visibility_config.value, "cloudwatch_metrics_enabled", true)
          metric_name                = visibility_config.value.metric_name
          sampled_requests_enabled   = lookup(visibility_config.value, "sampled_requests_enabled", true)
        }
      }
    }
  }
}
