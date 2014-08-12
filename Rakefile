require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
[:unit, :functional].each do |type|
  RSpec::Core::RakeTask.new(type) do |t|
    t.pattern = "spec/#{type}/**/*_spec.rb"
    t.rspec_opts = [].tap do |a|
      a.push('--color')
      a.push('--format progress')
    end.join(' ')
  end
end

namespace :travis do
  desc 'Run tests on Travis'
  task ci: %w(unit functional)
end

task default: %w(travis:ci)
