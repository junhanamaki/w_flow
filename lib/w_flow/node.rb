module WFlow
  class Node
    attr_reader :components

    def initialize(components, options = {})
      @components = components
      @options    = options

      validate_initialization!
    end

    def execute?(process)
      allowed_by_if_condition?(process) && allowed_by_unless_condition?(process)
    end

  protected

    def allowed_by_if_condition?(process)
      @options[:if].nil? || eval_condition(@options[:if], process)
    end

    def allowed_by_unless_condition?(process)
      @options[:unless].nil? || !eval_condition(@options[:unless], process)
    end

    def eval_condition(condition, process)
      ((condition.is_a?(String) || condition.is_a?(Symbol)) &&
       process.instance_eval(condition.to_s)) ||
      (condition.is_a?(Proc) && process.instance_eval(&condition))
    end

    def validate_initialization!
      unless @options.keys.all? { |key| [:if, :unless, :around].include?(key) }
        raise InvalidArgument, INVALID_KEYS
      end

      unless @components.length > 0
        raise InvalidArgument, INVALID_COMPONENTS
      end
    end
  end
end