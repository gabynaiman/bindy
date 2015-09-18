require 'minitest_helper'

describe Bindy do

  class TestContext < Bindy::Context

    def sum(*args)
      args.inject(:+)
    end

    def max(*args)
      args.max
    end

    def min(*args)
      args.min
    end

    def union(*args)
      args.inject(:|)
    end

    def merge(*args)
      args.inject({}) do |hash, var_name|
        hash.merge var_name.to_sym => var(var_name)
      end
    end

  end

  let(:variables) do
    {
      number: 5,
      boolean: true,
      nested: {
        value: 10.5
      },
      very:  {
        nested: { 
          value: 'hello world'
        }
      },
      lists: {
        head: [1,2,3],
        tail: [4,5,6]
      }
    }
  end

  let(:context) { TestContext.new variables }

  def assert_bind(expected, expression)
    context.bind(expression).must_equal expected
  end

  describe 'Expression binding' do
  
    it 'Number' do
      assert_bind 1,   '1'
      assert_bind 0.5, '0.5'
    end

    it 'String' do
      assert_bind 'sample text', 'sample text'
    end

    it 'Boolean' do
      assert_bind true,  'true'
      assert_bind false, 'false'
    end

    it 'Variables' do
      assert_bind true,          'var(boolean)'
      assert_bind 10.5,          'var(nested.value)'
      assert_bind 'hello world', 'var(very.nested.value)'

      error = proc { context.bind 'var(not.found)'}.must_raise RuntimeError
      error.message.must_equal 'Undefined variable not.found'
    end

    it 'Functions' do
      assert_bind 8, 'sum(3, 5)'
      assert_bind 4, 'max(4, 1)'
      assert_bind 2, 'min(2, 7)'
    end

    it 'Nested functions' do
      assert_bind [4,5,6,1,2,3], 'union(var(lists.tail), var(lists.head))'
    end

    it 'Function with variables' do
      expected = {
        number: 5,
        boolean: true,
        nested: {
          value: 10.5
        }
      }
      assert_bind expected, 'merge(number, boolean, nested)'
    end

  end

  describe 'Object binding' do

    it 'Hash' do
      hash = {
        account: 'var(number)',
        nested_value: 'var(nested.value)',
        very_nested_value: 'var(very.nested.value)'
      }

      expected = {
        account: 5 ,
        nested_value: 10.5, 
        very_nested_value: 'hello world'
      }

      assert_bind expected, hash
    end

    it 'Array' do
      array = [
        'var(number)',
        'var(nested.value)',
        'var(very.nested.value)'
       ]
 
      assert_bind [5, 10.5, 'hello world'], array
    end

    it 'Invalid' do
      error = proc { context.bind :invalid }.must_raise RuntimeError
      error.message.must_equal 'Unbindable invalid'
    end

  end

end