require 'rspec'
require 'cleanroom'

RSpec.configure do |config|
  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true

  # Force the expect syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Create and clear tmp_path on each run
  config.before(:each) do
    FileUtils.rm_rf(tmp_path)
    FileUtils.mkdir_p(tmp_path)
  end

  # Run specs in a random order
  config.order = 'random'
end

#
# The path on disk to the temporary directory.
#
# @param [String, Array<String>] paths
#   the extra path parameters to join
#
# @return [String]
#
def tmp_path(*paths)
  root = File.expand_path('../..', __FILE__)
  File.join('tmp', *paths)
end
