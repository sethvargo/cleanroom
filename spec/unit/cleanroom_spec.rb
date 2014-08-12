require 'spec_helper'

describe Cleanroom do
  let(:klass) do
    Class.new do
      include Cleanroom

      def exposed_method
        @called = true
      end
      expose :exposed_method

      def unexposed_method; end
    end
  end

  let(:instance) { klass.new }

  describe '.included' do
    let(:klass) { Class.new { include Cleanroom } }

    it 'extends the ClassMethods' do
      expect(klass).to be_a(Cleanroom::ClassMethods)
    end

    it 'includes the InstanceMethods' do
      expect(instance).to be_a(Cleanroom::InstanceMethods)
    end
  end

  describe '.extended' do
    let(:klass) { Class.new { extend Cleanroom } }

    it 'extends the ClassMethods' do
      expect(klass).to be_a(Cleanroom::ClassMethods)
    end

    it 'includes the InstanceMethods' do
      expect(instance).to be_a(Cleanroom::InstanceMethods)
    end
  end

  describe '.evaluate_file' do
    let(:path) { '/path/to/file' }
    let(:contents) { 'contents' }

    before do
      allow(File).to receive(:expand_path)
        .with(path)
        .and_return(path)

      allow(IO).to receive(:read)
        .with(path)
        .and_return(contents)

      allow(klass).to receive(:evaluate)
    end

    it 'gets the absolute path to the file' do
      expect(File).to receive(:expand_path).with(path).once
      klass.evaluate_file(instance, path)
    end

    it 'reads the contents to a string' do
      expect(IO).to receive(:read).with(path).once
      klass.evaluate_file(instance, path)
    end

    it 'evaluates the contents' do
      expect(klass).to receive(:evaluate).with(instance, contents, path, 1).once
      klass.evaluate_file(instance, path)
    end
  end

  describe '.evaluate' do
    let(:cleanroom) { double('Cleanroom.cleanroom') }
    let(:cleanroom_instance) { double('Cleanroom.cleanroom_instance') }

    let(:string) { '"hello"' }

    before do
      allow(cleanroom).to receive(:new)
        .with(instance)
        .and_return(cleanroom_instance)

      allow(cleanroom_instance).to receive(:instance_eval)

      allow(klass).to receive(:cleanroom)
        .and_return(cleanroom)
    end

    it 'creates a new cleanroom object' do
      expect(cleanroom).to receive(:new).with(instance).once
      klass.evaluate(instance, string)
    end

    it 'evaluates against the new cleanroom object' do
      expect(cleanroom_instance).to receive(:instance_eval).with(string).once
      klass.evaluate(instance, string)
    end
  end

  describe '.expose' do
    let(:klass) do
      Class.new do
        include Cleanroom

        def public_method; end

        protected
        def protected_method; end

        private
        def private_method; end
      end
    end

    it 'exposes the method when it is public' do
      expect { klass.expose(:public_method) }.to_not raise_error
      expect(klass.exposed_methods).to include(:public_method)
    end

    it 'raises an exception if the method is not defined' do
      expect { klass.expose(:no_method) }.to raise_error(NameError)
    end

    it 'raises an exception if the method is protected' do
      expect { klass.expose(:protected_method) }.to raise_error(NameError)
    end

    it 'raises an exception if the method is private' do
      expect { klass.expose(:private_method) }.to raise_error(NameError)
    end
  end

  describe '.exposed_methods' do
    it 'returns a hash' do
      expect(klass.exposed_methods).to be_a(Hash)
    end
  end

  describe '.cleanroom' do
    let(:klass) do
      Class.new do
        include Cleanroom

        def method_1
          @method_1 = true
        end
        expose :method_1

        def method_2
          @method_2 = true
        end
        expose :method_2
      end
    end

    it 'creates a new anonymous class each time' do
      a, b = klass.send(:cleanroom), klass.send(:cleanroom)
      expect(a).to_not be(b)
    end

    it 'creates a method for each exposed one on the proxy object' do
      cleanroom = klass.send(:cleanroom)

      expect(cleanroom).to be_public_method_defined(:method_1)
      expect(cleanroom).to be_public_method_defined(:method_2)
    end

    it 'calls the proxied method' do
      cleanroom = klass.send(:cleanroom).new(instance)
      cleanroom.method_1
      cleanroom.method_2

      expect(instance.instance_variable_get(:@method_1)).to be(true)
      expect(instance.instance_variable_get(:@method_2)).to be(true)
    end

    it 'prevents calls to the instance directly' do
      cleanroom = klass.send(:cleanroom).new(instance)
      expect {
        cleanroom.__instance__
      }.to raise_error(Cleanroom::InaccessibleError)

      expect {
        cleanroom.send(:__instance__)
      }.to raise_error(Cleanroom::InaccessibleError)
    end
  end

  describe '#evaluate_file' do
    let(:path) { '/path/to/file' }

    before do
      allow(klass).to receive(:evaluate_file)
        .with(instance, path)
    end

    it 'delegates to the class method' do
      expect(klass).to receive(:evaluate_file).with(instance, path)
      instance.evaluate_file(path)
    end

    it 'returns self' do
      expect(instance.evaluate_file(path)).to be(instance)
    end
  end

  describe '#evaluate' do
    let(:string) { '"hello"' }

    before do
      allow(klass).to receive(:evaluate)
        .with(instance, string)
    end

    it 'delegates to the class method' do
      expect(klass).to receive(:evaluate).with(instance, string)
      instance.evaluate(string)
    end

    it 'returns self' do
      expect(instance.evaluate(string)).to be(instance)
    end
  end

  context 'when evaluating a DSL subclass' do
    let(:parent) do
      Class.new do
        include Cleanroom

        def parent_method; end
        expose :parent_method
      end
    end

    let(:child) do
      Class.new(parent) do
        def child_method; end
        expose :child_method
      end
    end

    let(:instance) { child.new }

    it 'inherits the parent DSL methods' do
      expect {
        instance.evaluate("parent_method")
      }.to_not raise_error
    end

    it 'allows for custom DSL methods' do
      expect {
        instance.evaluate("child_method")
      }.to_not raise_error
    end

    it 'does not change the parent DSL' do
      expect {
        parent.new.evaluate("child_method")
      }.to raise_error(NameError)
    end
  end
end
