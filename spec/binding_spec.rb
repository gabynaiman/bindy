require 'minitest_helper'

describe Bindy do

  class TestContext < Bindy::Context

    def sum(*args)
      args.inject(:+)
    end

    def union(*args)
      args.inject(:|)
    end

    def merge(*args)
      args.inject({}) do |hash, var_name|
        hash.merge var_name.to_sym => var(var_name)
      end
    end

    def text_sample
      'text sample'
    end

    def get_number_1
      1
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

  def assert_evaluate(expected, expression)
    context.evaluate(expression).must_equal expected
  end

  it 'Number' do
    assert_evaluate 1,   '1'
    assert_evaluate 0.5, '0.5'
  end

  it 'String' do
    assert_evaluate 'sample text',   "'sample text'"
    assert_evaluate 'parenthesis()', "'parenthesis()'"
  end

  it 'Boolean' do
    assert_evaluate true,  'true'
    assert_evaluate false, 'false'
  end

  it 'Null' do
    assert_evaluate nil, 'null'
  end

  it 'Variables' do
    assert_evaluate true,          "var('boolean')"
    assert_evaluate 10.5,          "var('nested.value')"
    assert_evaluate 'hello world', "var('very.nested.value')"

    error = proc { context.evaluate "var('not.found')" }.must_raise ArgumentError
    error.message.must_equal 'Undefined variable not.found'
  end

  it 'Functions' do
    assert_evaluate 8, 'sum(3, 5)'
    assert_evaluate 'text sample', 'text_sample()'
    assert_evaluate 1, 'get_number_1()'
  end

  it 'Nested functions' do
    assert_evaluate [4,5,6,1,2,3], "union(var('lists.tail'), var('lists.head'))"
  end

  it 'Function with variables' do
    expected = {
      number: 5,
      boolean: true,
      nested: {
        value: 10.5
      }
    }
    assert_evaluate expected, "merge('number', 'boolean', 'nested')"
  end

  it 'Invalid' do
    error = proc { context.evaluate :xyz }.must_raise ArgumentError
    error.message.must_equal 'Expression must be a string (xyz)'
  end

end