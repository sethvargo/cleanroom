require 'spec_helper'

describe Cleanroom do
  let(:klass) do
    Class.new do
      NULL = Object.new.freeze unless defined?(NULL)

      include Cleanroom

      def method_1(val = NULL)
        if val.equal?(NULL)
          @method_1
        else
          @method_1 = val
        end
      end
      expose :method_1

      def method_2(val = NULL)
        if val.equal?(NULL)
          @method_2
        else
          @method_2 = val
        end
      end
      expose :method_2

      def method_3
        @method_3 = true
      end
    end
  end

  let(:instance) { klass.new }

  describe '#evaluate_file' do
    let(:path) { tmp_path('file.rb') }

    before do
      File.open(path, 'w') do |f|
        f.write <<-EOH.gsub(/^ {10}/, '')
          method_1 'hello'
          method_2 false
        EOH
      end
    end

    it 'evaluates the file' do
      instance.evaluate_file(path)
      expect(instance.method_1).to eq('hello')
      expect(instance.method_2).to be(false)
    end
  end

  describe '#evaluate' do
    let(:contents) do
      <<-EOH.gsub(/^ {8}/, '')
        method_1 'hello'
        method_2 false
      EOH
    end

    it 'evaluates the file' do
      instance.evaluate(contents)
      expect(instance.method_1).to eq('hello')
      expect(instance.method_2).to be(false)
    end
  end

  describe 'security' do
    it 'restricts access to __instance__' do
      expect {
        instance.evaluate("__instance__")
      }.to raise_error(Cleanroom::InaccessibleError)
    end

    it 'restricts access to __instance__ using :send' do
      expect {
        instance.evaluate("send(:__instance__)")
      }.to raise_error(Cleanroom::InaccessibleError)
    end

    it 'restricts access to defining new methods' do
      expect {
        instance.evaluate <<-EOH.gsub(/^ {12}/, '')
          self.class.class_eval do
            def new_method
              __instance__.method_3
            end
          end
        EOH
      }.to raise_error(Cleanroom::InaccessibleError)
      expect(instance.instance_variables).to_not include(:@method_3)
    end
  end
end
