Ruby Cleanroom
==============
[![Gem Version](http://img.shields.io/gem/v/cleanroom.svg)][gem]
[![Build Status](http://img.shields.io/travis/sethvargo/cleanroom.svg)][travis]
[![Dependency Status](http://img.shields.io/gemnasium/sethvargo/cleanroom.svg)][gemnasium]
[![Code Climate](http://img.shields.io/codeclimate/github/sethvargo/cleanroom.svg)][codeclimate]
[![Gittip](http://img.shields.io/gittip/sethvargo.svg)][gittip]

[gem]: https://rubygems.org/gems/cleanroom
[travis]: http://travis-ci.org/sethvargo/chef-suguar
[gemnasium]: https://gemnasium.com/sethvargo/cleanroom
[codeclimate]: https://codeclimate.com/github/sethvargo/cleanroom
[gittip]: https://www.gittip.com/sethvargo

Ruby is an excellent programming language for creating and managing custom DSLs, but how can you securely evaluate a DSL while explicitly controlling the methods exposed to the user? Our good friends `instance_eval` and `instance_exec` are great, but they expose all methods - public, protected, and private - to the user. Even worse, they expose the ability to accidentally or intentionally alter the behavior of the system! The cleanroom pattern is a safer, more convenient, Ruby-like approach for limiting the information exposed by a DSL while giving users the ability to write awesome code!

The cleanroom pattern is a unique way for more safely evaluating Ruby DSLs without adding additional overhead.


Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'cleanroom'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cleanroom


Usage
-----

### Setup
In order to use the cleanroom, you must first load the cleanroom gem:

```ruby
require 'cleanroom'
```

Next, for any file you wish to be evaluated as a DSL, include the module:

```ruby
class MyDSL
  include Cleanroom
end
```

### Writing DSLs
For each public method you with to expose as a DSL method, call `expose` after the method definition in your class:

```ruby
class MyDSL
  include Cleanroom

  def my_method
    # ...
  end
  expose :my_method

  def public_method
    # ...
  end

  private

  def private_method
    # ...
  end
end
```

In this example, `MyDSL` exposes two public API methods:

- `my_method`
- `public_method`

which would be accessible via:

```ruby
instance = MyDSL.new
instance.my_method
instance.public_method
```

MyDSL also exposes one DSL method:

- `my_method`

which would be accessible in a DSL file:

```ruby
my_method
```

The use of the `expose` method has the added advantage of clearly identifying which methods are available as part of the DSL.

The method `private_method` is never accessible in the DSL or as part of the public API.

### Evaluating DSLs
The cleanroom also includes the ability to more safely evaluate DSL files. Given an instance of a class, you can call `evaluate` or `evaluate_file` to read a DSL.

```ruby
instance = MyDSL.new

# Using a Ruby block
instance.evaluate do
  my_method
end

# Using a String
instance.evaluate "my_method"

# Given a file at /file
instance.evaluate_file('/file')
```

These same methods are available on the class as well, but require you pass in the instance:

```ruby
instance = MyDSL.new

# Using a Ruby block
MyDSL.evaluate(instance) do
  my_method
end

# Using a String
MyDSL.evaluate(instance) "my_method"

# Given a file at /file
MyDSL.evaluate_file(instance, '/file')
```

For both of these examples, _the given instance is modified_, meaning `instance` holds the values after the evaluation took place.


"Security"
----------
The cleanroom gem tries to prevent unauthorized variable access and attempts to alter the behavior of the system.

First, the underlying instance object is never stored in an instance variable. Due to the nature of `instance_eval`, it would be trivial for a malicious user to directly access methods on the delegate class.

```ruby
# Some DSL file
@instance #=> nil
```

Second, access to the underlying `instance` in the cleanroom is restricted to `self` by inspecting the `caller` attempts to access `__instance__` from outside of a method in the cleanroom will result in an error.

```ruby
# Some DSL file
__instance__ #=> Cleanroom::InaccessibleError
send(:__instance__) #=> Cleanroom::InaccessibleError
```

Third, the ability to create new methods on the cleanroom is also disabled:

```ruby
# Some DSL file
self.class.class_eval { } #=> Cleanroom::InaccessibleError
self.class.instance_eval { } #=> Cleanroom::InaccessibleError
```

Fourth, when delegating to the underlying instance object, `public_send` (as opposed to `send` or `__send__`) is used. Even if an attacker could somehow bypass the previous safeguards, they would be unable to call non-public methods on the delegate object.

If you find a security hole in the cleanroom implementation, please email me at the contact info found in my [GitHub profile](https://github.com/sethvargo). **Do not open an issue!**


Testing
-------
If you are using cleanroom in your DSLs, you will likely want to test a particular DSL method is exposed. Cleanroom packages some RSpec matchers for your convienence:

```ruby
# spec/spec_helper.rb
require 'rspec'
require 'cleanroom/rspec'
```

This will define the following matchers:

```ruby
# Check against an instance
expect(:my_method).to be_an_exposed_method_on(instance)

# Check against a class
expect(:my_method).to be_an_exposed_method_on(klass)

# Check against an instance
expect(instance).to have_exposed_method(:my_method)

# Check against a class
expect(klass).to have_exposed_method(:my_method)
```


Contributing
------------
1. Fork the project
1. Write tests
1. Run tests
1. Create a new Pull Request


License
-------
```text
Copyright 2014 Seth Vargo <sethvargo@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

