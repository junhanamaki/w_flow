module WFlow
  class Node
    VALID_KEYS = [:if, :unless, :around]

    def initialize(components, options = {})
      @components = components
      @options    = options

      validate_initialization!
    end

    def in_context_of(process, &block)
      return unless execute?(process)

      if @options[:around].nil?
        yield(@components)
      else
        process.expression_eval(@options[:around], block)
      end
    end

  protected

    def execute?(process)
      allowed_by_if_option?(process) && allowed_by_unless_option?(process)
    end

    def allowed_by_if_option?(process)
      @options[:if].nil? || process.expression_eval(@options[:if])
    end

    def allowed_by_unless_option?(process)
      @options[:unless].nil? || !process.expression_eval(@options[:unless])
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