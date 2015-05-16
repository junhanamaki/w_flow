module WFlow
  class Node
    VALID_KEYS = [:if, :unless, :around]

    attr_reader :components

    def initialize(components, options = {})
      @components = components
      @options    = options

      validate_initialization!
    end

    def in_context_of(process)
      return unless execute?(process)

      if @options[:around].nil?
        yield
      else
        process.eval_expression(@options[:around], '')
        yield
      end
    end

  protected

    def execute?(process)
      allowed_by_if_option?(process) && allowed_by_unless_option?(process)
    end

    def allowed_by_if_option?(process)
      @options[:if].nil? || process.eval_expression(@options[:if])
    end

    def allowed_by_unless_option?(process)
      @options[:unless].nil? || !process.eval_expression(@options[:unless])
    end

    def validate_initialization!
      unless @options.keys.all? { |k| VALID_KEYS.include?(k) }
        raise InvalidArgument, INVALID_KEYS.gsub('{keys}', VALID_KEYS.join(', '))
      end

      unless @components.length > 0
        raise InvalidArgument, INVALID_COMPONENTS
      end
    end
  end
end