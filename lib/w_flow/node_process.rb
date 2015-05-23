module WFlow
  class NodeProcess
    def initialize(owner_process, components, options)
      @owner_process = owner_process
      @components    = components

      @around            = options[:around]
      @if_condition      = options[:if]
      @unless_condition  = options[:unless]
      @stop_condition    = options[:stop]
      @failure_condition = options[:failure]
    end

    def execute?
      (@if_condition.nil? || node_eval(@if_condition)) &&
      (@unless_condition.nil? || node_eval(@unless_condition))
    end

    def cancel_error?
    end

    def cancel_failure?
    end

    def finalize
    end

    def rollback
    end

  protected

    def node_eval(object)
      if object.is_a?(String) || object.is_a?(Symbol)
        @owner.send(object.to_s)
      elsif object.is_a?(Proc)
        @owner.instance_exec(&object)
      elsif object == Process
        object.new.wflow_run(@flow)
      else
        raise InvalidArguments, UNKNOWN_EXPRESSION
      end
    end
  end
end