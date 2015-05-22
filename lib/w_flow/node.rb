module WFlow
  class Node
    def initialize(components, options)
      @components = components
      @if_condition      = options[:if]
      @unless_condition  = options[:unless]
      @around            = options[:around]
      @stop_condition    = options[:stop]
      @failure_condition = options[:failure]
    end

    def run(owner, flow)
      @owner = owner
      @flow  = flow

      if execute?
        flow.supervise(self) do
          if @around.nil?
            execute_node(owner, flow)
          else
            @around.call(Proc.new { execute_node(owner, flow) })
          end
        end
      end
    end

    def cancel_error?

    end

    def cancel_failure?

    end

  protected

    def execute?
      (@if_condition.nil? || node_eval(@if_condition)) &&
      (@unless_condition.nil? || node_eval(@unless_condition))
    end

    def execute_node
      @components.each { |component| node_eval(component) }
    end

    def node_eval(object)
      if object.is_a?(String) || object.is_a?(Symbol)
        @owner.send(object.to_s, *args)
      elsif object.is_a?(Proc)
        @owner.instance_exec(*args, &object)
      elsif object == Process
        object.new.wflow_run(@flow, *args)
      else
        raise InvalidArguments, UNKNOWN_EXPRESSION
      end
    end
  end
end