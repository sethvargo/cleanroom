# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cleanroom'

Gem::Specification.new do |spec|
  spec.name          = 'cleanroom'
  spec.version       = Cleanroom::VERSION
  spec.author        = 'Seth Vargo'
  spec.email         = 'sethvargo@gmail.com'
  spec.summary       = '(More) safely evaluate Ruby DSLs with cleanroom'
  spec.description   = <<-EOH.gsub(/^ {4}/, '').gsub(/\r?\n/, ' ').strip
    Ruby is an excellent programming language for creating and managing custom
    DSLs, but how can you securely evaluate a DSL while explicitly controlling
    the methods exposed to the user? Our good friends instance_eval and
    instance_exec are great, but they expose all methods - public, protected,
    and private - to the user. Even worse, they expose the ability to
    accidentally or intentionally alter the behavior of the system! The
    cleanroom pattern is a safer, more convenient, Ruby-like approach for
    limiting the information exposed by a DSL while giving users the ability to
    write awesome code!
  EOH
  spec.homepage      = 'https://github.com/sethvargo/cleanroom'
  spec.license       = 'Apache 2.0'

  spec.required_ruby_version = '>= 1.9.3'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
