CloudFormation do

  tags = []
  tags << { Key: 'Environment', Value: Ref('EnvironmentName') }
  tags << { Key: 'EnvironmentType', Value: Ref('EnvironmentType') }
  extra_tags = external_parameters.fetch(:extra_tags, {})
  extra_tags.each { |key,value| tags << { Key: FnSub(key), Value: FnSub(value) } }

  ipsets = external_parameters.fetch(:ipsets, [])
  ipsets.each do |name, properties|
    WAFv2_IPSet(name) {
      Name FnSub("${EnvironmentName}-#{name}")
      Addresses properties.has_key?('addresses') ? properties['addresses'] : []
      Description properties['desc'] if properties.has_key?('desc')
      IPAddressVersion properties.has_key?('version') ? properties['version'] : 'IPV4'
      Scope Ref(:Scope)
      Tags tags
    }
  end

  pattern_sets = external_parameters.fetch(:pattern_sets, [])
  pattern_sets.each do |name, properties|
    WAFv2_RegexPatternSet(name) {
      Description properties['desc'] if properties.has_key?('desc')
      Name FnSub("${EnvironmentName}-#{name}")
      RegularExpressionList properties['regexes']
      Scope Ref(:Scope)
      Tags tags
    }
  end

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
    Name FnSub("${EnvironmentName}-#{component_name}")
    Description FnSub("#{component_name}")
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
