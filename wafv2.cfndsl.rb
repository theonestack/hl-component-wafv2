CloudFormation do

  tags = []
  tags << { Key: 'Environment', Value: Ref('EnvironmentName') }
  tags << { Key: 'EnvironmentType', Value: Ref('EnvironmentType') }
  extra_tags = external_parameters.fetch(:extra_tags, {})
  extra_tags.each { |key,value| tags << { Key: FnSub(key), Value: FnSub(value) } }

  WAFv2_IPSet(:IPv4Whitelist) {
    Addresses external_parameters.fetch(:whitelist_ipv4, [])
    Description FnSub("${EnvironmentName} IPv4 Whitelist")
    IPAddressVersion 'IPV4'
    Scope Ref(:Scope)
    Tags tags
  }

  WAFv2_IPSet(:IPv6Whitelist) {
    Addresses external_parameters.fetch(:whitelist_ipv6, [])
    Description FnSub("${EnvironmentName} IPv6 Whitelist")
    IPAddressVersion 'IPV6'
    Scope Ref(:Scope)
    Tags tags
  }

  WAFv2_IPSet(:IPv4Blacklist) {
    Addresses external_parameters.fetch(:blacklist_ipv4, [])
    Description FnSub("${EnvironmentName} IPv4 Blacklist")
    IPAddressVersion 'IPV4'
    Scope Ref(:Scope)
    Tags tags
  }

  WAFv2_IPSet(:IPv6Blacklist) {
    Addresses external_parameters.fetch(:blacklist_ipv6, [])
    Description FnSub("${EnvironmentName} IPv4 Blacklist")
    IPAddressVersion 'IPV6'
    Scope Ref(:Scope)
    Tags tags
  }

  waf_rules = []

  waf_rules << {
    Name: 'IPSetWhitelist',
    Priority: 5,
    Action: {
      Allow: {}
    },
    VisibilityConfig: {
      SampledRequestsEnabled: cloudwatch['samples'],
      CloudWatchMetricsEnabled: cloudwatch['enabled'],
      MetricName: FnSub("#{cloudwatch['metric_name_prefix']}AWSManagedRulesCommonRuleSet")
    },
    Statement: {
      OrStatement: {
        Statements: [
          {
            IPSetReferenceStatement: {
              Arn: FnGetAtt(:IPv4Whitelist, :Arn)
            }
          },
          {
            IPSetReferenceStatement: {
              Arn: FnGetAtt(:IPv6Whitelist, :Arn)
            }
          }
        ]
      }
    }
  }

  waf_rules << {
    Name: 'IPSetBlacklist',
    Priority: 6,
    Action: {
      Block: {}
    },
    VisibilityConfig: {
      SampledRequestsEnabled: cloudwatch['samples'],
      CloudWatchMetricsEnabled: cloudwatch['enabled'],
      MetricName: FnSub("#{cloudwatch['metric_name_prefix']}AWSManagedRulesCommonRuleSet")
    },
    Statement: {
      OrStatement: {
        Statements: [
          {
            IPSetReferenceStatement: {
              Arn: FnGetAtt(:IPv4Blacklist, :Arn)
            }
          },
          {
            IPSetReferenceStatement: {
              Arn: FnGetAtt(:IPv6Blacklist, :Arn)
            }
          }
        ]
      }
    }
  }

  waf_rules << {
    Name: 'AWSManagedRulesCommonRuleSet',
    Priority: 10,
    OverrideAction: {
      None: {}
    },
    VisibilityConfig: {
      SampledRequestsEnabled: cloudwatch['samples'],
      CloudWatchMetricsEnabled: cloudwatch['enabled'],
      MetricName: FnSub("#{cloudwatch['metric_name_prefix']}AWSManagedRulesCommonRuleSet")
    },
    Statement: {
      ManagedRuleGroupStatement: {
        VendorName: 'AWS',
        Name: 'AWSManagedRulesCommonRuleSet'
      }
    }
  }

  waf_rules << {
    Name: 'AWSManagedRulesAdminProtectionRuleSet',
    Priority: 20,
    OverrideAction: {
      None: {}
    },
    VisibilityConfig: {
      SampledRequestsEnabled: cloudwatch['samples'],
      CloudWatchMetricsEnabled: cloudwatch['enabled'],
      MetricName: FnSub("#{cloudwatch['metric_name_prefix']}AWSManagedRulesAdminProtectionRuleSet")
    },
    Statement: {
      ManagedRuleGroupStatement: {
        VendorName: 'AWS',
        Name: 'AWSManagedRulesAdminProtectionRuleSet'
      }
    }
  }

  waf_rules << {
    Name: 'AWSManagedRulesKnownBadInputsRuleSet',
    Priority: 30,
    OverrideAction: {
      None: {}
    },
    VisibilityConfig: {
      SampledRequestsEnabled: cloudwatch['samples'],
      CloudWatchMetricsEnabled: cloudwatch['enabled'],
      MetricName: FnSub("#{cloudwatch['metric_name_prefix']}AWSManagedRulesKnownBadInputsRuleSet")
    },
    Statement: {
      ManagedRuleGroupStatement: {
        VendorName: 'AWS',
        Name: 'AWSManagedRulesKnownBadInputsRuleSet'
      }
    }
  }

  waf_rules << {
    Name: 'AWSManagedRulesSQLiRuleSet',
    Priority: 40,
    OverrideAction: {
      None: {}
    },
    VisibilityConfig: {
      SampledRequestsEnabled: cloudwatch['samples'],
      CloudWatchMetricsEnabled: cloudwatch['enabled'],
      MetricName: FnSub("#{cloudwatch['metric_name_prefix']}AWSManagedRulesSQLiRuleSet")
    },
    Statement: {
      ManagedRuleGroupStatement: {
        VendorName: 'AWS',
        Name: 'AWSManagedRulesSQLiRuleSet'
      }
    }
  }

  waf_rules << {
    Name: "AWSManagedRulesUnixRuleSet",
    Priority: 50,
    OverrideAction: {
      None: {}
    },
    VisibilityConfig: {
      SampledRequestsEnabled: cloudwatch['samples'],
      CloudWatchMetricsEnabled: cloudwatch['enabled'],
      MetricName: FnSub("#{cloudwatch['metric_name_prefix']}AWSManagedRulesUnixRuleSet")
    },
    Statement: {
      ManagedRuleGroupStatement: {
        VendorName: "AWS",
        Name: "AWSManagedRulesUnixRuleSet"
      }
    }
  }

  waf_rules << {
    Name: "AWSManagedRulesWindowsRuleSet",
    Priority: 60,
    OverrideAction: {
      None: {}
    },
    VisibilityConfig: {
      SampledRequestsEnabled: cloudwatch['samples'],
      CloudWatchMetricsEnabled: cloudwatch['enabled'],
      MetricName: FnSub("#{cloudwatch['metric_name_prefix']}AWSManagedRulesWindowsRuleSet")
    },
    Statement: {
      ManagedRuleGroupStatement: {
        VendorName: "AWS",
        Name: "AWSManagedRulesWindowsRuleSet"
      }
    }
  } 

  waf_rules << {
    Name: "AWSManagedRulesPHPRuleSet",
    Priority: 70,
    OverrideAction: {
      None: {}
    },
    VisibilityConfig: {
      SampledRequestsEnabled: cloudwatch['samples'],
      CloudWatchMetricsEnabled: cloudwatch['enabled'],
      MetricName: FnSub("#{cloudwatch['metric_name_prefix']}AWSManagedRulesPHPRuleSet")
    },
    Statement: {
      ManagedRuleGroupStatement: {
        VendorName: "AWS",
        Name: "AWSManagedRulesPHPRuleSet"
      }
    }
  } 

  waf_rules << {
    Name: "AWSManagedRulesWordPressRuleSet",
    Priority: 80,
    OverrideAction: {
      None: {}
    },
    VisibilityConfig: {
      SampledRequestsEnabled: cloudwatch['samples'],
      CloudWatchMetricsEnabled: cloudwatch['enabled'],
      MetricName: FnSub("#{cloudwatch['metric_name_prefix']}AWSManagedRulesWordPressRuleSet")
    },
    Statement: {
      ManagedRuleGroupStatement: {
        VendorName: "AWS",
        Name: "AWSManagedRulesWordPressRuleSet"
      }
    }
  } 

  waf_rules << {
    Name: "AWSManagedRulesAmazonIpReputationList",
    Priority: 90,
    OverrideAction: {
      None: {}
    },
    VisibilityConfig: {
      SampledRequestsEnabled: cloudwatch['samples'],
      CloudWatchMetricsEnabled: cloudwatch['enabled'],
      MetricName: FnSub("#{cloudwatch['metric_name_prefix']}AWSManagedRulesAmazonIpReputationList")
    },
    Statement: {
      ManagedRuleGroupStatement: {
        VendorName: "AWS",
        Name: "AWSManagedRulesAmazonIpReputationList"
      }
    }
  } 

  waf_rules << {
    Name: "AWSManagedRulesAnonymousIpList",
    Priority: 100,
    OverrideAction: {
      None: {}
    },
    VisibilityConfig: {
      SampledRequestsEnabled: cloudwatch['samples'],
      CloudWatchMetricsEnabled: cloudwatch['enabled'],
      MetricName: FnSub("#{cloudwatch['metric_name_prefix']}AWSManagedRulesAnonymousIpList")
    },
    Statement: {
      ManagedRuleGroupStatement: {
        VendorName: "AWS",
        Name: "AWSManagedRulesAnonymousIpList"
      }
    }
  } 

  # Loop over each rule in the confic and either override the default or add a new rule
  rules.each do |rule|
    
    # remove a rule from the rule list if enabled is set to false
    if rule.has_key?('enabled')
      if rule['enabled'] == false
        waf_rules.reject! { |r| r.is_a?(Hash) && r[:Name] == rule['name'] }
        next
      end
    end

    selected_rule = waf_rules.detect {|r| r.is_a?(Hash) && r[:Name] == rule['name']}

    # If the rule doesn't exist, create it
    if selected_rule.nil?
      selected_rule = {
        Name: rule['name'],
        Priority: rule['priority'],
        VisibilityConfig: {
          SampledRequestsEnabled: cloudwatch['samples'],
          CloudWatchMetricsEnabled: cloudwatch['enabled'],
          MetricName: FnSub("#{cloudwatch['metric_name_prefix']}#{rule['name']}")
        }
      }
      waf_rules << selected_rule
    end

    if rule.has_key?('priority')
      selected_rule[:Priority] = rule['priority']
    end

    if rule.has_key?('action')
      selected_rule[:Action] = rule['action']
    end

    if rule.has_key?('override_action')
      selected_rule[:OverrideAction] = rule['override_action']
    end

    if rule.has_key?('statement')
      selected_rule[:Statement] = rule['statement']
    end

    if rule.has_key?('cloudwatch')
      if rule['cloudwatch'].has_key?('sample')
        selected_rule[:VisibilityConfig][:SampledRequestsEnabled] = rule['cloudwatch']['sample']
      end

      if rule['cloudwatch'].has_key?('enabled')
        selected_rule[:VisibilityConfig][:CloudWatchMetricsEnabled] = rule['cloudwatch']['enabled']
      end

      if rule['cloudwatch'].has_key?('metric_name')
        selected_rule[:VisibilityConfig][:MetricName] = rule['cloudwatch']['metric_name']
      end
    end

    if rule.has_key?('conditional')
      if rule['conditional'] == true
        Condition("#{rule['name']}Enabled", FnEquals("Enable#{rule['name']}Rule", 'true'))
        # remove the rule from the waf_rules array and add it back wrapped in a FnIf condition
        waf_rules.reject! { |r| r[:Name] == rule['name'] }
        waf_rules << FnIf("#{rule['name']}Enabled", selected_rule, Ref('AWS::NoValue'))
      end
    end
  end

  WAFv2_WebACL(:WAF) {
    Scope Ref(:Scope)
    VisibilityConfig({
      SampledRequestsEnabled: cloudwatch['samples'],
      CloudWatchMetricsEnabled: cloudwatch['enabled'],
      MetricName: FnSub("#{cloudwatch['metric_name_prefix']}WAFWebACL")
    })
    DefaultAction({
      Allow: {}
    })
    Rules(waf_rules)
  }

  Output(:WAFArn) {
    Value FnGetAtt(:WAF, :Arn)
    Export FnSub("${EnvironmentName}-#{component_name}-waf-arn")
  }

end
