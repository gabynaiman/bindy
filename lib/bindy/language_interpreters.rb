module Bindy
  module Language

    class << self

      def parse(expression)
        parsed_expression = parser.parse expression
        raise parser.failure_reason unless parsed_expression
        parsed_expression
      end

      private

      def parser
        @parser ||= LanguageParser.new
      end

    end

    class Function < Treetop::Runtime::SyntaxNode
      def evaluate(context)
        context.public_send name, *arguments.map { |a| a.evaluate context }
      end

      def name
        identifier.text_value
      end

      def arguments
        if arg_list.text_value.empty?
          []
        elsif arg_list.respond_to?(:to_a)
          arg_list.to_a 
        else
          [arg_list]
        end
      end
    end

    class ArgList < Treetop::Runtime::SyntaxNode
      def to_a
        [expression] | (arg_list.respond_to?(:to_a) ? arg_list.to_a : [arg_list])
      end
    end

    class LiteralString < Treetop::Runtime::SyntaxNode
      def evaluate(context)
        value.text_value
      end
    end

    class LiteralInteger < Treetop::Runtime::SyntaxNode
      def evaluate(context)
        text_value.to_i
      end
    end

    class LiteralFloat < Treetop::Runtime::SyntaxNode
      def evaluate(context)
        text_value.to_f
      end
    end

    class LiteralTrue < Treetop::Runtime::SyntaxNode
      def evaluate(context)
        true
      end
    end

    class LiteralFalse < Treetop::Runtime::SyntaxNode
      def evaluate(context)
        false
      end
    end

  end
end