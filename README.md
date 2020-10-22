# wafv2 CfHighlander component

```sh
kurgan add wafv2
```

## Requirements

### Parameters

| Name | Use | Default | Global | Type | Allowed Values |
| ---- | --- | ------- | ------ | ---- | -------------- |
| EnvironmentName | Tagging | dev | true | string
| EnvironmentType | Tagging | development | true | string | ['development','production']
| Scope | Sets the AWS scope of the WebACL | REGIONAL | false | string | ['REGIONAL','CLOUDFRONT']

### Configuration