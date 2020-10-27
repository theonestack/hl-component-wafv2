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
  rules = external_parameters.fetch(:rules, {})
  # Loop over each rule in the confic and either override the default or add a new rule
  rules.each do |name, properties|
    
    # remove a rule from the rule list if enabled is set to false
    if properties.has_key?('enabled')
      if properties['enabled'] == false
        next
      end
    end

    rule = {
      Name: name,
      Priority: properties['priority'],
      VisibilityConfig: {
        SampledRequestsEnabled: cloudwatch['samples'],
        CloudWatchMetricsEnabled: cloudwatch['enabled'],
        MetricName: FnSub("#{cloudwatch['metric_name_prefix']}#{name}")
      },
      Statement: properties['statement']
    }

    if !properties.dig('action').nil?
      rule[:Action] = properties['action']
    elsif !properties.dig('override_action').nil?
      rule[:OverrideAction] = properties['override_action']
    else
      rule[:Action] = { Block: {} }
    end

    if !properties.dig('cloudwatch', 'sample').nil?
      rule[:VisibilityConfig][:SampledRequestsEnabled] = properties['cloudwatch']['sample']
    end

    if !properties.dig('cloudwatch', 'enabled').nil?
      rule[:VisibilityConfig][:CloudWatchMetricsEnabled] = properties['cloudwatch']['enabled']
    end

    if !properties.dig('cloudwatch', 'metric_name').nil?
      rule[:VisibilityConfig][:MetricName] = FnSub(properties['cloudwatch']['metric_name'])
    end

    if properties.dig('conditional') == true
      Condition("#{name}Enabled", FnEquals("Enable#{name}Rule", 'true'))
      waf_rules << FnIf("#{name}Enabled", rule, Ref('AWS::NoValue'))
    else
      waf_rules << rule
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
