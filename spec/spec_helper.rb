require 'jenkins_pivotal'

spec_root = File.expand_path '../', __FILE__
Dir[File.join(spec_root, 'support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'
end
