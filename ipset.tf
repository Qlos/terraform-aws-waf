locals {
  ip_sets = {
    for rule in var.ip_set_reference_statement_rules :
    format("%s-ip-set", rule.name) => rule.statement.ip_set
    if try(rule.statement.ip_set, null) != null && try(rule.statement.arn, null) == null
  }
}

resource "aws_wafv2_ip_set" "default" {
  for_each = local.ip_sets

  name               = format("%s-%s", local.id, each.key)
  description        = lookup(each.value, "description", null)
  scope              = var.scope
  ip_address_version = each.value.ip_address_version
  addresses          = each.value.addresses

  tags = merge(local.base_tags, { Name = format("%s-%s", local.id, each.key) })
}
