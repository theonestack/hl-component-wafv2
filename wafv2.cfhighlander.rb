CfhighlanderTemplate do
  Name 'wafv2'
  Description "wafv2 - #{component_version}"

  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', allowedValues: ['development','production'], isGlobal: true
    ComponentParam 'Scope', 'REGIONAL', allowedValues: ['REGIONAL','CLOUDFRONT']

    rules.each do |rule,properties|
      if properties.dig('conditional') == true
        ComponentParam "Enable#{rule['name']}Rule", 'true', allowedValues: ['true', 'false']
      end
    end
  end

end
