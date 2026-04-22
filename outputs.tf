output "arn" {
  value       = one(aws_wafv2_web_acl.default[*].arn)
  description = "ARN of the created WebACL"
}

output "id" {
  value       = one(aws_wafv2_web_acl.default[*].id)
  description = "ID of the created WebACL"
}

output "capacity" {
  value       = one(aws_wafv2_web_acl.default[*].capacity)
  description = "WCU capacity consumed by the WebACL"
}

output "ip_set_ids" {
  value       = { for k, v in aws_wafv2_ip_set.default : k => v.id }
  description = "Map of created IP set IDs keyed by the rule-name suffix"
}
