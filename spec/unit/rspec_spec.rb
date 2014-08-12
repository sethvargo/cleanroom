require 'spec_helper'
require 'cleanroom/rspec'

describe 'RSpec matchers' do
  let(:klass) do
    Class.new do
      include Cleanroom

      def method_1; end
      expose :method_1

      def method_2; end
    end
  end

  let(:instance) { klass.new }

  describe '#be_an_exposed_method_on' do
    context 'when given a class' do
      it 'is true when the method is exposed' do
        expect(:method_1).to be_an_exposed_method_on(klass)
      end

      it 'is false when the method exists, but is not exposed' do
        expect(:method_2).to_not be_an_exposed_method_on(klass)
      end

      it 'is false when the method is not exposed' do
        expect(:method_3).to_not be_an_exposed_method_on(klass)
      end
    end

    context 'when given an instance' do
      it 'is true when the method is exposed' do
        expect(:method_1).to be_an_exposed_method_on(instance)
      end

      it 'is false when the method exists, but is not exposed' do
        expect(:method_2).to_not be_an_exposed_method_on(instance)
      end

      it 'is false when the method is not exposed' do
        expect(:method_3).to_not be_an_exposed_method_on(instance)
      end
    end
  end

  describe '#have_exposed_method' do
    context 'when given a class' do
      it 'is true when the method is exposed' do
        expect(klass).to have_exposed_method(:method_1)
      end

      it 'is false when the method exists, but is not exposed' do
        expect(klass).to_not have_exposed_method(:method_2)
      end

      it 'is false when the method is not exposed' do
        expect(klass).to_not have_exposed_method(:method_3)
      end
    end

    context 'when given an instance' do
      it 'is true when the method is exposed' do
        expect(instance).to have_exposed_method(:method_1)
      end

      it 'is false when the method exists, but is not exposed' do
        expect(instance).to_not have_exposed_method(:method_2)
      end

      it 'is false when the method is not exposed' do
        expect(instance).to_not have_exposed_method(:method_3)
      end
    end
  end
end
