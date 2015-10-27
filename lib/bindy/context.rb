module Bindy

  class Context

    attr_reader :variables

    def initialize(variables={})
      @variables = variables
    end

    def evaluate(expression)
      raise ArgumentError, "Expression must be a string (#{expression})" unless expression.kind_of?(String)
      Language.parse(expression).evaluate(self)
    end

    def var(name)
      name.split('.').inject(variables) do |vars, key| 
        vars.fetch(key) { vars.fetch(key.to_sym) }
      end
    rescue KeyError
      raise ArgumentError, "Undefined variable #{name}"
    end

  end
end