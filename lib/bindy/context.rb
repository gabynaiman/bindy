module Bindy

  class Context

    attr_reader :variables

    def initialize(variables)
      @variables = variables
    end

    def bind(object)
      case object
        when Hash   then bind_hash object
        when Array  then bind_array object
        when String then bind_string object
        else raise "Unbindable #{object}"
      end
    end

    def var(name)
      name.split('.').inject(variables) do |vars, key| 
        vars.fetch(key, vars.fetch(key.to_sym))
      end
    rescue KeyError
      raise "Undefined variable #{name}"
    end

    private

    def bind_hash(hash)
      hash.each_with_object({}) do |(k,v),h|
        h[k] = bind v
      end
    end

    def bind_array(array)
      array.map { |v| bind v }
    end

    def bind_string(string)
      Language.parse(string).evaluate(self)
    end

  end
end