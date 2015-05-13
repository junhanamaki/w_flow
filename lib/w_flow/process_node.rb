module WFlow
  class ProcessNode
    def initialize(elements, options)
      @elements = elements
      @options  = options
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
  end
end