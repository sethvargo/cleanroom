#
# Copyright 2014 Seth Vargo <sethvargo@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative '../cleanroom'

unless defined?(RSpec)
  require 'rspec'
end

#
# Assert a given method is exposed on a class.
#
# @example Checking against an instance
#   expect(:method_1).to be_an_exposed_method_on(instance)
#
# @example Checking against a class
#   expect(:method_1).to be_an_exposed_method_on(klass)
#
RSpec::Matchers.define :be_an_exposed_method_on do |object|
  match do |name|
    if object.is_a?(Class)
      object.exposed_methods.key?(name.to_sym)
    else
      object.class.exposed_methods.key?(name.to_sym)
    end
  end
end

#
# Assert a given class or instance has an exposed method.
#
# @example Checking against an instance
#   expect(instance).to have_exposed_method(:method_1)
#
# @example Checking against a class
#   expect(klass).to have_exposed_method(:method_1)
#
RSpec::Matchers.define :have_exposed_method do |name|
  match do |object|
    if object.is_a?(Class)
      object.exposed_methods.key?(name.to_sym)
    else
      object.class.exposed_methods.key?(name.to_sym)
    end
  end
end

