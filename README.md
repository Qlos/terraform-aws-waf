
# terraform-aws-waf

This project is **100% Open Source**, build and develop by DevOps Team from [Qlos.com](https://qlos.com)

## About

Terraform module to create an [AWS WAFv2 WebACL](https://docs.aws.amazon.com/waf/latest/developerguide/waf-chapter.html) with inline custom rules, IP sets, and references to AWS or marketplace managed rule groups.

The module supports the full action matrix (`allow`, `block`, `count`, `captcha`, `challenge`) on every custom rule type (IP set reference, byte match, regex match) and per-rule `captcha_config` with a configurable immunity time.

Supported rule types:

- `ip_set_reference_statement_rules` with inline IP set creation
- `byte_match_statement_rules`
- `regex_match_statement_rules`
- `managed_rule_group_statement_rules` (AWS / marketplace managed rule groups)

## License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

```text
The MIT License (MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Source: <https://opensource.org/licenses/MIT>
```

See [LICENSE](LICENSE) for full details.

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

### Resources

| Name | Type |
|------|------|
| [aws_wafv2_web_acl.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_ip_set.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace component of the generated resource name | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage component of the generated resource name | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Logical name of the WebACL | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Free-form description attached to the WebACL | `string` | `null` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | `CLOUDFRONT` or `REGIONAL` | `string` | n/a | yes |
| <a name="input_default_action"></a> [default\_action](#input\_default\_action) | Default action when no rule matches (`allow` or `block`) | `string` | `"allow"` | no |
| <a name="input_visibility_config"></a> [visibility\_config](#input\_visibility\_config) | WebACL-level CloudWatch visibility | `object` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the WebACL and IP sets | `map(string)` | `{}` | no |
| <a name="input_ip_set_reference_statement_rules"></a> [ip\_set\_reference\_statement\_rules](#input\_ip\_set\_reference\_statement\_rules) | IP set rules (inline or referenced) | `any` | `null` | no |
| <a name="input_byte_match_statement_rules"></a> [byte\_match\_statement\_rules](#input\_byte\_match\_statement\_rules) | Byte match rules | `any` | `null` | no |
| <a name="input_regex_match_statement_rules"></a> [regex\_match\_statement\_rules](#input\_regex\_match\_statement\_rules) | Regex match rules | `any` | `null` | no |
| <a name="input_managed_rule_group_statement_rules"></a> [managed\_rule\_group\_statement\_rules](#input\_managed\_rule\_group\_statement\_rules) | AWS / marketplace managed rule groups | `any` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| arn | ARN of the created WebACL |
| id | ID of the created WebACL |
| capacity | WCU capacity consumed |
| ip\_set\_ids | Map of created IP set IDs keyed by rule-name suffix |

### Naming convention

The WebACL name is `{namespace}-{stage}-{name}` and each generated IP set is `{namespace}-{stage}-{name}-{rule_name}-ip-set`.

### Examples

```hcl
module "waf" {
  source  = "github.com/Qlos/terraform-aws-waf"

  namespace = "acme"
  stage     = "prod"
  name      = "edge"

  scope          = "CLOUDFRONT"
  default_action = "allow"

  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "acme-prod-edge"
    sampled_requests_enabled   = true
  }

  ip_set_reference_statement_rules = [
    {
      name     = "allow-office-ips"
      priority = 1
      action   = "allow"
      statement = {
        ip_set = {
          description        = "Office egress IPs"
          ip_address_version = "IPV4"
          addresses          = ["203.0.113.10/32"]
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "allow-office-ips"
        sampled_requests_enabled   = true
      }
    },
  ]

  byte_match_statement_rules = [
    {
      name     = "captcha-search"
      priority = 100
      action   = "captcha"
      captcha_config = {
        immunity_time_property = { immunity_time = 300 }
      }
      statement = {
        positional_constraint = "STARTS_WITH"
        search_string         = "/search/"
        field_to_match        = { uri_path = true }
        text_transformation   = [{ priority = 0, type = "LOWERCASE" }]
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "captcha-search"
        sampled_requests_enabled   = true
      }
    },
  ]

  managed_rule_group_statement_rules = [
    {
      name            = "aws-common-rule-set"
      priority        = 200
      override_action = "none"
      statement = {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "aws-common-rule-set"
        sampled_requests_enabled   = true
      }
    },
  ]
}
```
