module WFlow
  class ProcessNode
    def initialize(elements, options = {})
      @elements = elements
      @options  = options

      validate_initialization!
    end

    def execute_node?(owner_process)
      allowed_by_if_condition?(owner_process) &&
      allowed_by_unless_condition?(owner_process)
    end

  protected

    def allowed_by_if_condition?(owner_process)
      @options[:if].nil? || eval_condition(@options[:if], owner_process)
    end

    def allowed_by_unless_condition?(owner_process)
      @options[:unless].nil? || !eval_condition(@options[:unless], owner_process)
    end

    def eval_condition(condition, owner_process)
      ((condition.is_a?(String) || condition.is_a?(Symbol)) &&
       owner_process.instance_eval(condition.to_s)) ||
      (condition.is_a?(Proc) && owner_process.instance_eval(&condition))
    end

    def validate_initialization!
      unless @options.keys.all? { |key| [:if, :unless, :around].include?(key) }
        raise InvalidArgument, INVALID_OPTIONS
      end

      unless @elements.length > 0
        raise InvalidArgument, INVALID_ELEMENTS
      end
    end

    INVALID_OPTIONS  = 'valid option keys are :if, :unless and :around'
    INVALID_ELEMENTS =
      <<-EOS
        Argument 'elements' for WFLow::ProcessNode must be an array containing
        at least one WFlow::Process, String, Symbol or Proc
      EOS
  end
end