RSpec.configure do |config|
  # set SKIP_VALIDATE to compile the templates without validating them against CloudFormation
  config.before(:context) { @validate = ENV['SKIP_VALIDATE'] ? '--no-validate' : '--validate' }
end
