# wafv2 CfHighlander component

## Build status
![cftest workflow](https://github.com/theonestack/hl-component-wafv2/actions/workflows/rspec.yaml/badge.svg)
## Parameters

| Name | Use | Default | Global | Type | Allowed Values |
| ---- | --- | ------- | ------ | ---- | -------------- |
| EnvironmentName | Tagging | dev | true | string
| EnvironmentType | Tagging | development | true | string | development / production
| Scope | Sets the AWS scope of the WebACL | REGIONAL | false | string | REGIONAL / CLOUDFRONT
## Outputs/Exports

| Name | Value | Exported |
| ---- | ----- | -------- |
| RestApiId | RestApiId | true
| RestApiStage | RestApiStage | true

## Included Components
<none>

## Example Configuration
### Highlander
```
    Component name: 'wafv2', template: 'wafv2' do
      parameter name: 'Scope', value: 'CLOUDFRONT'
    end
```
### API Gateway (Rest) Configuration
```
rules:
  AWSManagedRulesAmazonIpReputationList:
    enabled: true
  AWSManagedRulesKnownBadInputsRuleSet:
    enabled: true
  AWSManagedRulesSQLiRuleSet:
    enabled: true
  IPBlacklistRule:
    enabled: true
    priority: 10
    action:
      Block: {}
    statement:
      IPSetReferenceStatement:
        Arn:
          Fn::GetAtt: ['Blacklist', 'Arn']
ipsets:
  Blacklist:
    desc: No more Google DNS
    addresses:
    - 8.8.8.8/32

```

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
      Block: {}
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

### IP Sets

to create static ip white and black lists use the following config:

create the IPSet with an optional description. 

```yaml
ipsets:
  Whitelist:
    # optional
    desc: ips to whitelist for my waf
    addresses:
    - 127.0.0.1/32
```
the default ip version is `IPv4` but can be overridden to `IPv6` by setting the `version: IPv6`.

create a rule using the IPSet

```yaml
rules:
  IPWhitelistRule:
    priority: 10
    action:
      Allow: {}
    statement: 
      OrStatement:
        Statements:
        - IPSetReferenceStatement:
            Arn: 
              # reference the ipset name in your config
              Fn::GetAtt: ['Whitelist', 'Arn']
```

### Regex Pattern Sets

create the RegexPatternSet with an optional description specifying a list of regexes

```yaml
pattern_sets:
  MyPattern:
    desc: test pattern
    regexes:
    - '^[\w\-]+$'
```

create a rule using the RegexPatternSet

```yaml
rules:
  Regex:
    priority: 10
    action:
      Allow: {}
    statement: 
      RegexPatternSetReferenceStatement:
        Arn:
          # reference the pattern set name in your config
          Fn::GetAtt: ['MyPattern', 'Arn']
        # set the field amd transform properities acording to 
        # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-wafv2-webacl-fieldtomatch.html
        FieldToMatch:
          AllQueryArguments: {}
        TextTransformations:
          - Priority: 1
            Type: NONE
```

## Cfhighlander Setup

install cfhighlander [gem](https://github.com/theonestack/cfhighlander)

```bash
gem install cfhighlander
```

or via docker

```bash
docker pull theonestack/cfhighlander
```
## Testing Components

Running the tests

```bash
cfhighlander cftest wafv2
```