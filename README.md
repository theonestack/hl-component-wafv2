# wafv2 CfHighlander component

```sh
kurgan add wafv2
```

## Parameters

| Name | Use | Default | Global | Type | Allowed Values |
| ---- | --- | ------- | ------ | ---- | -------------- |
| EnvironmentName | Tagging | dev | true | string
| EnvironmentType | Tagging | development | true | string | development / production
| Scope | Sets the AWS scope of the WebACL | REGIONAL | false | string | REGIONAL / CLOUDFRONT

## Configuration

### Managed Rules

These are rules that are defined in the [wafv2.config.yaml](wafv2.config.yaml) file.

To enable or modify the rules use the following syntax

```yml
rules:
  # specify the matching rule name as the key
  AWSManagedRulesCommonRuleSet:
    # when enabled is true the rule is added to the WAF
    enabled: true
    # conditional adds the rule to the WAF if the cloudformation parameter to enable the rule is set to 'true' at runtime
    conditional: false
    # alter the default priority
    priority: 30
```

| Rule | Default Priority | Enabled By Default | AWS Managed |
| ---- | ---------------- | ------------------ | ----------- |
| IPSetWhitelist | 10 | false | false |
| IPSetBlacklist | 20 | false | false |
| AWSManagedRulesCommonRuleSet | 30 | true | true |
| AWSManagedRulesAdminProtectionRuleSet | 40 | false | true |
| AWSManagedRulesKnownBadInputsRuleSet | 50 | false | true |
| AWSManagedRulesSQLiRuleSet | 60 | false | true |
| AWSManagedRulesLinuxRuleSet | 70 | false | true |
| AWSManagedRulesUnixRuleSet | 80 | false | true |
| AWSManagedRulesWindowsRuleSet | 90 | false | true |
| AWSManagedRulesPHPRuleSet | 100 | false | true |
| AWSManagedRulesWordPressRuleSet | 110 | false | true |
| AWSManagedRulesAmazonIpReputationList | 120 | false | true |
| AWSManagedRulesAnonymousIpList | 130 | false | true |

Visit the following AWS docs to get the details of the AWS managed rules
https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-list.html

### Custom Rules

custom rules can be added using the following syntax

```yaml
rules:
  MyRule:
    # set the rule priority
    priority: 25
    # specify the action, default action is to block
    action:
      Black: {}
    # set the rule statement using the cloudformation waf rules syntax
    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-wafv2-webacl-statementone.html
    statement:
      StatementOne: {}
```

for example creating a IP block on a rate based limit rule.
this rule will temporarily block an IP if it reaches 1000 requests within a 5 minute time frame.

```yaml
rules:
  IPRatelimitBlock:
    priority: 25
    action:
      Block: {}
    statement:
      RateBasedStatement:
        AggregateKeyType: IP
        Limit: 1000
```

### Static IP White/Black Lists

to create static ip white and black lists use the following config

```yaml
# enable the rules
rules:
  # whitelist
  IPSetWhitelist:
    enable: true
  # blacklist
  IPSetBlacklist:
    enable: true
```

2 IP sets are created for each rule, 1 each for IPv4 and IPv6.

to add ips to the ip sets use the following config

```yaml
whitelist_ipv4:
- '1.1.1.1/32'

whitelist_ipv6:
- '2606:4700:4700::1111/128'

blacklist_ipv4:
- '1.0.0.1/32'

blacklist_ipv6:
- '2606:4700:4700::1001/128'
```